# frozen_string_literal: true

require "ar_lazy_preload/contexts/base_context"
require "ar_lazy_preload/contexts/auto_preload_context"
require "ar_lazy_preload/contexts/lazy_preload_context"
require "ar_lazy_preload/contexts/temporary_preload_config"

module ArLazyPreload
  class Context
    # Initiates lazy preload context for given records
    def self.register(records:, association_tree: nil, auto_preload: false)
      return if records.empty?

      if ArLazyPreload.config.auto_preload? || auto_preload
        Contexts::AutoPreloadContext.new(records: records)
      elsif association_tree.any?
        Contexts::LazyPreloadContext.new(
          records: records,
          association_tree: association_tree
        )
      end
    end
  end
end
