# frozen_string_literal: true

module ArLazyPreload
  module Base
    extend ActiveSupport::Concern

    module ClassMethods
      delegate :lazy_preload, to: :all
    end

    included do
      attr_reader :lazy_preload_context

      def lazy_preload_context=(value)
        @lazy_preload_context = value
      end

      def preload_association_lazily(association)
        lazy_preload_context.preload_association(association) if lazy_preload_context.present?
      end
    end
  end
end
