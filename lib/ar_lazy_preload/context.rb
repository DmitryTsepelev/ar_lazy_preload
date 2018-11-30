# frozen_string_literal: true

require "ar_lazy_preload/contexts/base_context"
require "ar_lazy_preload/contexts/auto_preload_context"
require "ar_lazy_preload/contexts/lazy_preload_context"

module ArLazyPreload
  class Context
    # Initiates lazy preload context for given records
    def self.register(records:, association_tree:)
      return if records.empty?

      if ArLazyPreload.config.auto_preload?
        ArLazyPreload::Contexts::AutoPreloadContext.new(records: records)
      elsif association_tree.any?
        ArLazyPreload::Contexts::LazyPreloadContext.new(
          records: records,
          association_tree: association_tree
        )
      end
    end
  end
end
