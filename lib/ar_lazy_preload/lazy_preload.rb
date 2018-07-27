# frozen_string_literal: true

module ArLazyPreload
  module LazyPreload
    extend ActiveSupport::Concern

    included do
      def lazy_preload_values
        get_value(:lazy_preload)
      end

      def lazy_preload_values=(value)
        set_value(:lazy_preload, value)
      end

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
