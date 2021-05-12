# frozen_string_literal: true

module ArLazyPreload
  # ActiveRecord::AssociationRelation patch for setting up lazy_preload_values based on
  # owner context
  module AssociationRelation
    def initialize(*args)
      super(*args)
      setup_preloading_context unless ArLazyPreload.config.auto_preload?
    end

    delegate :owner, :reflection, to: :proxy_association, prefix: true
    delegate :lazy_preload_context, to: :proxy_association_owner

    private

    def setup_preloading_context
      return if lazy_preload_context.nil?
      return if lazy_preload_context.association_tree.nil?

      association_tree_builder = AssociationTreeBuilder.new(lazy_preload_context.association_tree)
      subtree = association_tree_builder.subtree_for(proxy_association_reflection.name)

      lazy_preload!(subtree)
    end
  end
end
