# frozen_string_literal: true

module ArLazyPreload
  # ActiveRecord::AssociationRelation patch for setting up lazy_preload_values based on
  # owner context
  module CollectionProxy
    # `ArLazyPreload::Relation` should already be prepended
    # since `CollectionProxy` < `Relation`

    private

    def _ar_lazy_preload_records
      target
    end
  end
end
