# frozen_string_literal: true

module ArLazyPreload
  # ActiveRecord::Base patch with lazy preloading support
  module Base
    def self.included(base)
      base.class.delegate :lazy_preload, to: :all
      base.class.delegate :preload_associations_lazily, to: :all

      base.after_create { try_setup_auto_preload_context }

      base.extend(ClassMethods)
    end

    attr_accessor :lazy_preload_context

    delegate :try_preload_lazily, to: :lazy_preload_context, allow_nil: true

    def reload(options = nil)
      super(options).tap { try_setup_auto_preload_context }
    end

    def skip_preload
      lazy_preload_context&.records&.delete(self)
      self.lazy_preload_context = nil
      self
    end

    def try_setup_auto_preload_context
      ArLazyPreload::Context.register(records: [self]) if ArLazyPreload.config.auto_preload?
    end

    module ClassMethods
      def find_by(*args)
        super(*args).tap { |object| object&.try_setup_auto_preload_context }
      end
    end
  end
end
