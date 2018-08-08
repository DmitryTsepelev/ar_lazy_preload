# frozen_string_literal: true

require "ar_lazy_preload/association_tree_builder"

module ArLazyPreload
  # This class is responsible for building context for associated records. Given a list of records
  # belonging to the same context and association name it will create and attach a new context to
  # the associated records based on the parent association tree.
  class AssociatedContextBuilder
    # Initiates lazy preload context the records loaded lazily
    def self.prepare(*args)
      new(*args).perform
    end

    attr_reader :parent_context, :association_name

    # :parent_context - root context
    # :association_name - lazily preloaded association name
    def initialize(parent_context:, association_name:)
      @parent_context = parent_context
      @association_name = association_name
    end

    # Takes all the associated records for the records, attached to the :parent_context and creates
    # a preloading context for them
    def perform
      records_by_class = parent_context.records.group_by(&:class)

      associated_records = records_by_class.map do |klass, klass_records|
        associated_records_for(klass, klass_records)
      end.flatten

      Context.register(records: associated_records, association_tree: child_association_tree)
    end

    private

    def child_association_tree
      AssociationTreeBuilder.new(parent_context.association_tree).subtree_for(association_name)
    end

    def associated_records_for(klass, records)
      record_associations = records.map { |record| record.send(association_name) }
      reflection = klass.reflect_on_association(association_name)
      reflection.collection? ? record_associations.map(&:target).flatten : record_associations
    end
  end
end
