# frozen_string_literal: true

module ArLazyPreload
  # ActiveRecord::Base patch with lazy preloading support
  module Base
    def self.included(base)
      base.class.delegate :lazy_preload, to: :all
    end

    attr_accessor :lazy_preload_context

    delegate :try_preload_lazily, to: :lazy_preload_context, allow_nil: true

    def skip_preload
      lazy_preload_context&.records&.delete(self)
      self.lazy_preload_context = nil
      self
    end
  end
end
