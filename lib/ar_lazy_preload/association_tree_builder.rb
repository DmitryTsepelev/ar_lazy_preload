# frozen_string_literal: true

module ArLazyPreload
  # This class is responsible for building association subtrees from a given association tree
  # For instance, given a following tree `[:users, { users: :comments }]`,
  # #subtree_for will build a subtree `[:comments]` when :users argument is passed
  class AssociationTreeBuilder
    attr_reader :association_tree

    def initialize(association_tree)
      @association_tree = association_tree
    end

    def subtree_for(association)
      association_tree.select { |node| node.is_a?(Hash) }.map { |node| node[association] }
    end
  end
end
