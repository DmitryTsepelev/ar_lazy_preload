# frozen_string_literal: true

module ArLazyPreload
  module Contexts
    # This class is responsible for lazy preloading. It contains a tree of associations, which were
    # requested to be loaded lazily.
    class LazyPreloadContext < BaseContext
      attr_reader :association_tree

      # :records - array of ActiveRecord instances
      # :association_tree - list of symbols or hashes representing a tree of preloadable
      # associations
      def initialize(records:, association_tree:)
        @association_tree = association_tree

        super(records: records)
      end

      protected

      def association_needs_preload?(association_name)
        association_tree.any? do |node|
          case node
          when Symbol
            node == association_name
          when Hash
            node.key?(association_name)
          end
        end
      end
    end
  end
end
