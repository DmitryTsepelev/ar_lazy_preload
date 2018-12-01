# frozen_string_literal: true

require "set"
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
      if ArLazyPreload.config.auto_preload?
        # `association_tree` is unnecessary when auto preload is enabled
        return ArLazyPreload::Context.new(records: records, association_tree: nil)
      end
      return if records.empty? || association_tree.empty? && !ArLazyPreload.config.auto_preload?

      ArLazyPreload::Context.new(records: records, association_tree: association_tree)
    end

    attr_reader :records, :association_tree

    # :records - array of ActiveRecord instances
    # :association_tree - list of symbols or hashes representing a tree of preloadable associations
    def initialize(records:, association_tree:)
      @records = records
      @association_tree = association_tree

      @records.each do |record|
        next if record.nil?

        record.lazy_preload_context = self
      end
    end

    # This method checks if the association is present in the association_tree and preloads for all
    # objects in the context it if needed.
    def try_preload_lazily(association_name)
      return unless association_needs_preload?(association_name)

      preloader.preload(records, association_name)
      AssociatedContextBuilder.prepare(parent_context: self, association_name: association_name)
      # Our tracking of loading state
      # Otherwise `#preload` will be called many times even when association is loaded
      mark_association_as_loaded(association_name)
    end

    private

    def association_needs_preload?(association_name, node_tree = association_tree)
      return false if association_loaded?(association_name)
      return true if ArLazyPreload.config.auto_preload?

      node_tree.any? do |node|
        case node
        when Symbol
          node == association_name
        when Hash
          node.key?(association_name)
        end
      end
    end

    def mark_association_as_loaded(association_name)
      loaded_association_names.add(association_name)
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
  end
end
