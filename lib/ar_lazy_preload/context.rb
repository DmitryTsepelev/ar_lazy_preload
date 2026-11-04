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

    # Initiates auto preload context for given records, unless they already have one or skip
    # preloading
    def self.register_auto_preload(records:)
      records_without_context, records_with_context =
        records.partition { |record| record.lazy_preload_context.nil? }
      # The whole context is replaced, so its records keep loading their associations together
      lazy_contexts = records_with_context.map(&:lazy_preload_context).uniq.reject(&:auto_preload?)

      records_to_register =
        records_without_context.reject(&:skip_preload?) + lazy_contexts.flat_map(&:records)
      register(records: records_to_register, auto_preload: true)
    end
  end
end
