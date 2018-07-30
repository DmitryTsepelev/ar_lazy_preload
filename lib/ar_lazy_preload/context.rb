# frozen_string_literal: true

require "ar_lazy_preload/associated_context_builder"

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

      AssociatedContextBuilder.new(
        parent_context: self,
        association_name: association_name
      ).perform
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

    def preloader
      @preloader ||= ActiveRecord::Associations::Preloader.new
    end
  end
end
