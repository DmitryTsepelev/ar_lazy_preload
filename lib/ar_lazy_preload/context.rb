# frozen_string_literal: true

require "ar_lazy_preload/association_tree_builder"

module ArLazyPreload
  # This class is responsible for holding a connection between a list of ActiveRecord::Base objects
  # which have been loaded by the same instance of ActiveRecord::Relation. It also contains a tree
  # of associations, which were requested to be loaded lazily.
  # Calling #preload_association method will cause loading of ALL associated objects for EACH
  # ecord when requested association is found in the association tree
  class Context
    attr_reader :model, :records, :association_tree

    def initialize(model:, records:, association_tree:)
      @model = model
      @records = records.compact
      @association_tree = association_tree

      @records.each { |record| record.lazy_preload_context = self }
    end

    def preload_association(association_name)
      return unless association_needs_preload?(association_name)
      preloader.preload(records, association_name)

      child_associations = child_associations_builder.build_subtree_for(association_name)
      setup_child_preloading(association_name, child_associations) if child_associations.present?
    end

    private

    def association_needs_preload?(association_name)
      association_tree.any? do |node|
        if node.is_a?(Symbol)
          node == association_name
        elsif node.is_a?(Hash)
          node.key?(association_name)
        end
      end
    end

    # rubocop:disable Metrics/MethodLength
    def setup_child_preloading(association_name, child_associations)
      # TODO: consider moving to the separate class
      reflection = model.reflect_on_association(association_name)

      associated_records =
        if reflection.collection?
          records.map { |record| record.send(association_name).target }.flatten
        else
          records.map { |record| record.send(association_name) }
        end

      return if associated_records.blank?

      Context.new(
        model: reflection.klass,
        records: associated_records,
        association_tree: child_associations
      )
    end
    # rubocop:enable Metrics/MethodLength

    def preloader
      @preloader ||= ActiveRecord::Associations::Preloader.new
    end

    def child_associations_builder
      @child_associations_builder ||= AssociationTreeBuilder.new(association_tree)
    end
  end
end
