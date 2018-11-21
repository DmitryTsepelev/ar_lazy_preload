# frozen_string_literal: true

require "ar_lazy_preload/associated_context_builder"

module ArLazyPreload
  # This class is responsible for holding a connection between a list of ActiveRecord::Base objects
  # which have been loaded by the same instance of ActiveRecord::Relation. It also contains a tree
  # of associations, which were requested to be loaded lazily.
  # Calling #preload_association method will cause loading of ALL associated objects for EACH
  # ecord when requested association is found in the association tree.
  class Context
    # Initiates lazy preload context for given records
    def self.register(records:, association_tree:)
      return if records.empty? || association_tree.empty? && !ArLazyPreload.config.auto_preload?

      ArLazyPreload::Context.new(records: records, association_tree: association_tree)
    end

    attr_reader :records, :association_tree

    # :records - array of ActiveRecord instances
    # :association_tree - list of symbols or hashes representing a tree of preloadable associations
    def initialize(records:, association_tree:)
      @records = records.compact
      @association_tree = association_tree

      @records.each { |record| record.lazy_preload_context = self }
    end

    # This method checks if the association is present in the association_tree and preloads for all
    # objects in the context it if needed.
    def try_preload_lazily(association_name)
      return unless association_needs_preload?(association_name)

      preloader.preload(records, association_name)
      AssociatedContextBuilder.prepare(parent_context: self, association_name: association_name)
    end

    private

    def association_needs_preload?(association_name, node_tree = association_tree)
      return true if ArLazyPreload.config.auto_preload?

      node_tree.any? do |node|
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
