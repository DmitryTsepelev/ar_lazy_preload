# frozen_string_literal: true

module ArLazyPreload
  # This class is responsible for building association subtrees from a given association tree
  # For instance, given a following tree `[:users, { users: :comments }]`,
  # #subtree_for will build a subtree `[:comments]` when :users argument is passed
  class AssociationTreeBuilder
    attr_reader :association_tree

    def initialize(association_tree)
      # Since `association_tree` can be an array or a single hash
      # Converting it to an array is easier for processing
      # like jquery
      @association_tree =
        case association_tree
        when Array
          association_tree
        when Hash
          [association_tree]
        else
          raise NotImplementedError,
                "unexpected association_tree with class #{association_tree.class}"
        end.select { |node| node.is_a?(Hash) }
    end

    def subtree_for(association)
      subtree_cache[association]
    end

    private

    def subtree_cache
      @subtree_cache ||= Hash.new do |hash, association|
        hash[association] = association_tree.map { |node| node[association] }.flatten
      end
    end
  end
end
