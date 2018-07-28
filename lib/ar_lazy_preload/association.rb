# frozen_string_literal: true

module ArLazyPreload
  module Association
    extend ActiveSupport::Concern

    included do
      alias_method :old_load_target, :load_target

      def load_target
        owner.preload_association_lazily(reflection.name)
        old_load_target
      end
    end
  end
end
