# frozen_string_literal: true

require "ar_lazy_preload/association_tree_builder"

module ArLazyPreload
  # This class is responsible for building context for associated records. Given a list of records
  # belonging to the same context and association name it will create and attach a new context to
  # the associated records based on the parent association tree.
  class AssociatedContextBuilder
    attr_reader :parent_context, :association_name

    def initialize(parent_context:, association_name:)
      @parent_context = parent_context
      @association_name = association_name
    end

    delegate :records, :association_tree, :model, to: :parent_context

    # Takes all the associated records for the records, attached to the :parent_context and creates
    # a preloading context for them
    def perform
      return if child_association_tree.empty? || associated_records.empty?

      Context.new(
        model: reflection.klass,
        records: associated_records,
        association_tree: child_association_tree
      )
    end

    private

    def child_association_tree
      @child_association_tree ||= association_tree_builder.subtree_for(association_name)
    end

    def association_tree_builder
      @association_tree_builder ||= AssociationTreeBuilder.new(association_tree)
    end

    def associated_records
      @associated_records ||=
        if reflection.collection?
          record_associations.map(&:target).flatten
        else
          record_associations
        end
    end

    def reflection
      @reflection = model.reflect_on_association(association_name)
    end

    def record_associations
      @record_associations ||= records.map { |record| record.send(association_name) }
    end
  end
end
