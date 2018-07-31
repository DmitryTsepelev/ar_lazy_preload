# frozen_string_literal: true

module ArLazyPreload
  # ActiveRecord::Association patch with a hook for lazy preloading
  module Association
    def load_target
      owner.try_preload_lazily(association_name)
      super
    end

    private

    def association_name
      @association_name ||= reflection.name
    end
  end
end
