# frozen_string_literal: true

module ArLazyPreload
  class Context
    attr_reader :records, :preloadable_associations

    def initialize(records, preloadable_associations)
      @records = records
      @preloadable_associations = preloadable_associations
    end

    def preload_association(association)
      return unless association_needs_preload(association)

      preloader.preload(records, association)

      preloaded_records = records.map { |record| record.send(association) }

      context = build_child_context(association, preloaded_records)
      preloaded_records.each { |record| record.lazy_preload_context = context } if context.present?
    end

    private

    def preloader
      @preloader ||= ActiveRecord::Associations::Preloader.new
    end

    def association_needs_preload(association)
      preloadable_associations.include?(association)

      preloadable_associations.any? do |preloadable_association|
        if preloadable_association.is_a?(Symbol)
          preloadable_association == association
        elsif preloadable_association.is_a?(Hash)
          preloadable_association.key?(association)
        end
      end
    end

    def build_child_context(association, preloaded_records)
      lazy_preload_values =
        preloadable_associations.each_with_object([]) do |preloadable_association, result|
          result << preloadable_association[association] if preloadable_association.is_a?(Hash)
        end
      return if lazy_preload_values.blank?

      ArLazyPreload::Context.new(preloaded_records, lazy_preload_values)
    end
  end
end
