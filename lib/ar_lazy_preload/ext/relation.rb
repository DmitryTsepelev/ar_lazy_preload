# frozen_string_literal: true

require "ar_lazy_preload/context"

module ArLazyPreload
  module Relation
    def load
      need_context = !loaded?
      old_load_result = super
      setup_lazy_preload_context if need_context
      old_load_result
    end

    def lazy_preload(*args)
      check_if_method_has_arguments!(:lazy_preload, args)
      spawn.lazy_preload!(*args)
    end

    def lazy_preload!(*args)
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
      return if lazy_preload_values.blank? || @records.blank?
      ArLazyPreload::Context.new(@records, lazy_preload_values)
    end
  end
end
