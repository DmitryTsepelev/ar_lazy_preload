# frozen_string_literal: true

require "set"
require "ar_lazy_preload/associated_context_builder"
require "ar_lazy_preload/preloader"

module ArLazyPreload
  module Contexts
    # This is a base context class, which is responsible for holding a connection between a list of
    # ActiveRecord::Base objects which have been loaded by the same instance of
    # ActiveRecord::Relation.
    class BaseContext
      attr_reader :records

      # :records - array of ActiveRecord instances
      def initialize(records:)
        @records = records.dup
        @records.compact!
        @records.uniq!
        @records.each { |record| record.lazy_preload_context = self }
      end

      # @api
      def association_tree; nil; end

      # This method checks if the association should be loaded and preloads it for all
      # objects in the context it if needed.
      def try_preload_lazily(association_name)
        return if association_loaded?(association_name) ||
                  !association_needs_preload?(association_name)

        perform_preloading(association_name)
      end

      def auto_preload?
        false
      end

      protected

      def association_needs_preload?(_association_name)
        raise NotImplementedError
      end

      private

      def perform_preloading(association_name)
        filtered_records = records.select do |record|
          preloadable_record?(association_name, record)
        end

        preload_records(association_name, filtered_records)
        loaded_association_names.add(association_name)

        # Prepare context for intermediate through associations
        prepare_through_association_contexts(association_name, filtered_records)

        AssociatedContextBuilder.prepare(
          parent_context: self,
          association_name: association_name
        )
      end

      # Prepare one context for the intermediate records of a through chain. The intermediate
      # association is marked as loaded for the whole context, so only when every record of the
      # context that has it has it loaded: the Rails preloader does not always load it (for
      # example with a scope on the through association or an STI target), and records outside
      # the chain can have an association with the same name. Then it must stay available for
      # lazy preloading.
      def prepare_through_association_contexts(association_name, filtered_records)
        intermediate_owners(association_name, filtered_records).each do |name, owners|
          next if association_loaded?(name)

          register_intermediate_records(owners, name)
          loaded_association_names.add(name) if loaded_for_all_records?(name)
        end
      end

      def intermediate_owners(association_name, filtered_records)
        filtered_records.group_by(&:class).each_with_object({}) do |(klass, klass_records), owners|
          through_association_chain(association_name, klass).each do |name|
            (owners[name] ||= []).concat(klass_records)
          end
        end
      end

      # A record that already has a context keeps it, because that context can hold the records of
      # other owners too.
      def register_intermediate_records(owners, name)
        associations = owners.map { |owner| owner.association(name) }.select(&:loaded?)
        targets = associations.flat_map(&:target).compact.reject(&:lazy_preload_context)
        ArLazyPreload::Context.register(records: targets, auto_preload: true)
      end

      def loaded_for_all_records?(name)
        records.all? do |record|
          !preloadable_record?(name, record) || record.association(name).loaded?
        end
      end

      # Extract chain of intermediate association names for through associations
      def through_association_chain(association_name, klass)
        reflection = klass.reflect_on_association(association_name)
        return [] unless reflection&.options&.key?(:through)

        chain = []
        current_reflection = reflection

        while current_reflection&.options&.key?(:through)
          through_name = current_reflection.options[:through].to_sym
          chain.unshift(through_name)
          current_reflection = klass.reflect_on_association(through_name)
        end

        chain
      end

      # Method preloads associations for the specific sets of the records
      # and provides automatically provides context for the records
      # loaded using `includes` inside Relation#preload_associations with the
      # help of the TemporaryPreloadConfig
      def preload_records(association_name, records)
        TemporaryPreloadConfig.within_context do
          ArLazyPreload::Preloader.new(records, [association_name]).preload
        end
      end

      def association_loaded?(association_name)
        loaded_association_names.include?(association_name)
      end

      def loaded_association_names
        @loaded_association_names ||= Set.new
      end

      def preloadable_record?(association_name, record)
        preloadable_reflections_cache.dig(record.class, association_name)
      end

      def preloadable_reflections_cache
        @preloadable_reflections_cache ||= Hash.new do |hash, klass|
          associations = klass.reflect_on_all_associations

          hash[klass] = associations.each_with_object({}) do |reflection, cache|
            cache[reflection.name] = preloadable_reflection?(klass, reflection)
          end
        end
      end

      def preloadable_reflection?(klass, reflection)
        scope = reflection.scope
        preloadable_scope = scope&.arity&.zero? || ::ActiveRecord::VERSION::MAJOR >= 7
        through_reflection =
          reflection.options[:through] && klass.reflect_on_association(reflection.options[:through])
        preloadable_through_reflection =
          through_reflection && preloadable_reflection?(klass, through_reflection)

        (!scope || preloadable_scope) && (!through_reflection || preloadable_through_reflection)
      end
    end
  end
end
