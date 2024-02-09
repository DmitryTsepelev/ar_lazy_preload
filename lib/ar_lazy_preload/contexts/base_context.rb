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

        AssociatedContextBuilder.prepare(
          parent_context: self,
          association_name: association_name
        )
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
