# frozen_string_literal: true

require "forwardable"
require "ar_lazy_preload/association_tree_builder"

module ArLazyPreload
  # This class is responsible for building context for associated records. Given a list of records
  # belonging to the same context and association name it will create and attach a new context to
  # the associated records based on the parent association tree.
  class AssociatedContextBuilder
    extend Forwardable

    attr_reader :parent_context, :association_name

    def initialize(parent_context:, association_name:)
      @parent_context = parent_context
      @association_name = association_name
    end

    def perform
      return if child_association_tree.blank? || associated_records.blank?

      Context.new(
        model: reflection.klass,
        records: associated_records,
        association_tree: child_association_tree
      )
    end

    private

    def child_association_tree
      @child_association_tree ||= association_tree_builder.build_subtree_for(association_name)
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

    def_delegators :parent_context, :records, :association_tree, :model
  end
end