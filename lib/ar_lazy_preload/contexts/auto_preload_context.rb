# frozen_string_literal: true

module ArLazyPreload
  module Contexts
    # This class is responsible for automatic association preloading
    class AutoPreloadContext < BaseContext
      protected

      def association_needs_preload?(_association_name)
        true
      end
    end
  end
end
