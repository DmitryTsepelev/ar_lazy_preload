# frozen_string_literal: true

require "ar_lazy_preload/child_associations_builder"

module ArLazyPreload
  class Context
    attr_reader :records, :association_values

    def initialize(records, association_values)
      @records = records
      @association_values = association_values

      records.each { |record| record.lazy_preload_context = self }
    end

    def preload_association(association)
      return unless association_needs_preload?(association)
      preloader.preload(records, association)

      child_associations = child_associations_builder.build(association)
      setup_child_preloading(association, child_associations) if child_associations.present?
    end

    private

    def association_needs_preload?(association)
      association_values.any? do |value|
        if value.is_a?(Symbol)
          value == association
        elsif value.is_a?(Hash)
          value.key?(association)
        end
      end
    end

    def setup_child_preloading(association, child_associations)
      reflection = records.first.class.reflect_on_association(association)
      # TODO: HasAndBelongsToManyReflection ?
      # TODO: HasOneReflection ?
      associated_records = records.map { |record| record.send(association) }
      associated_records = associated_records.map(&:target).flatten if reflection.collection?

      Context.new(associated_records, child_associations)
    end

    def preloader
      @preloader ||= ActiveRecord::Associations::Preloader.new
    end

    def child_associations_builder
      @child_associations_builder ||= ChildAssociationsBuilder.new(association_values)
    end
  end
end
