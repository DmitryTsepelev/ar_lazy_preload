# frozen_string_literal: true

module ArLazyPreload
  # ActiveRecord::Association patch with a hook for lazy preloading
  module Association
    def load_target
      owner.try_preload_lazily(reflection.name)
      super
    end
  end
end
