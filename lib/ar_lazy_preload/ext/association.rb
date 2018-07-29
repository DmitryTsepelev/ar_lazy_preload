# frozen_string_literal: true

module ArLazyPreload
  module Association
    def load_target
      association = reflection.name
      owner.preload_association_lazily(association)
      super
    end
  end
end
