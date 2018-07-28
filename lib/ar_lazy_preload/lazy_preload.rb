# frozen_string_literal: true

module ArLazyPreload
  module LazyPreload
    extend ActiveSupport::Concern

    included do
      attr_accessor :lazy_preload_values

      def lazy_preload(*args)
        check_if_method_has_arguments!(:lazy_preload, args)
        args.reject!(&:blank?)
        args.flatten!
        self.lazy_preload_values = args
        self
      end
    end
  end
end
