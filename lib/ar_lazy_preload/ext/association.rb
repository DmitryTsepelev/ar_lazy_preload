# frozen_string_literal: true

module ArLazyPreload
  # ActiveRecord::Association patch with a hook for lazy preloading
  module Association
    def load_target
      owner.preload_association_for_context(association_name)
      super
    end

    private

    def association_name
      @association_name ||= reflection.name
    end
  end
end
