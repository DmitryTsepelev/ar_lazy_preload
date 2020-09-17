# frozen_string_literal: true

require "ar_lazy_preload/association_tree_builder"

module ArLazyPreload
  # This class is responsible for building context for associated records. Given a list of records
  # belonging to the same context and association name it will create and attach a new context to
  # the associated records based on the parent association tree.
  class AssociatedContextBuilder
    # Initiates lazy preload context the records loaded lazily
    def self.prepare(**args)
      new(**args).perform
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
    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    def perform
      associated_records = parent_context.records.flat_map do |record|
        next if record.nil?

        reflection = reflection_cache[record.class]
        next if reflection.nil?

        record_association = record.association(association_name)
        reflection.collection? ? record_association.target : record_association.reader
      end

      Context.register(
        records: associated_records,
        association_tree: child_association_tree,
        auto_preload: parent_context.auto_preload?
      )
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

    private

    def child_association_tree
      # `association_tree` is unnecessary when auto preload is enabled
      return nil if parent_context.auto_preload?

      AssociationTreeBuilder.new(parent_context.association_tree).subtree_for(association_name)
    end

    def reflection_cache
      @reflection_cache ||= Hash.new do |hash, klass|
        hash[klass] = klass.reflect_on_association(association_name)
      end
    end
  end
end
