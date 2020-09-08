# frozen_string_literal: true

require "set"
require "ar_lazy_preload/associated_context_builder"

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
          reflection_names_cache[record.class].include?(association_name)
        end
        preloader.preload(filtered_records, association_name)

        loaded_association_names.add(association_name)

        AssociatedContextBuilder.prepare(
          parent_context: self,
          association_name: association_name
        )
      end

      def association_loaded?(association_name)
        loaded_association_names.include?(association_name)
      end

      def loaded_association_names
        @loaded_association_names ||= Set.new
      end

      def preloader
        @preloader ||= ActiveRecord::Associations::Preloader.new
      end

      def reflection_names_cache
        @reflection_names_cache ||= Hash.new do |hash, klass|
          hash[klass] = klass.reflect_on_all_associations.map(&:name)
        end
      end
    end
  end
end
