# frozen_string_literal: true

module ArLazyPreload
  # ActiveRecord::AssociationRelation patch for setting up lazy_preload_values based on
  # owner context
  module AssociationRelation
    def initialize(*args)
      super(*args)

      # lazy_preload_values is unnecessary when auto preload enabled
      return if ArLazyPreload.config.auto_preload?

      context = owner.lazy_preload_context
      return if context.nil?

      association_tree_builder = AssociationTreeBuilder.new(context.association_tree)
      subtree = association_tree_builder.subtree_for(reflection.name)

      lazy_preload!(subtree)
    end

    delegate :owner, :reflection, to: :proxy_association
  end
end
