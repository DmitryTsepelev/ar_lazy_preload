# frozen_string_literal: true

module ArLazyPreload
  module Association
    extend ActiveSupport::Concern

    included do
      alias_method :load_target_source, :load_target

      def load_target
        if owner.respond_to?(:perform_lazy_preloading)
          owner.perform_lazy_preloading(reflection.name)
        end
        load_target_source
      end
    end
  end
end
