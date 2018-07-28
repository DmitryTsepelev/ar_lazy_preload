# frozen_string_literal: true

require "ar_lazy_preload/context"

module ArLazyPreload
  module Relation
    extend ActiveSupport::Concern

    included do
      alias_method :old_load, :load

      def load
        old_load_result = old_load
        setup_lazy_preload_context
        old_load_result
      end

      def lazy_preload(*args)
        check_if_method_has_arguments!(:lazy_preload, args)
        args.reject!(&:blank?)
        args.flatten!
        self.lazy_preload_values += args
        self
      end

      def lazy_preload_values
        @lazy_preload_values ||= []
      end

      private

      def lazy_preload_values=(values)
        @lazy_preload_values = values
      end

      def setup_lazy_preload_context
        context = Context.new(@records, lazy_preload_values)
        @records.each { |record| record.lazy_preload_context = context }
      end
    end
  end
end
