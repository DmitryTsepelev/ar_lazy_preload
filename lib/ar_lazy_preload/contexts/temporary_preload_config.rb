# frozen_string_literal: true

module ArLazyPreload
  module Contexts
    # Preload config that used to enable preloading only for specfic part of the application
    class TemporaryPreloadConfig
      THREAD_KEY = "temporary_preload_context_enabled"

      class << self
        def enabled?
          Thread.current[THREAD_KEY] == true
        end

        def within_context
          Thread.current[THREAD_KEY] = true
          yield
        ensure
          Thread.current[THREAD_KEY] = nil
        end
      end
    end
  end
end
