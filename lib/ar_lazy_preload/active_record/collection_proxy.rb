# frozen_string_literal: true

module ArLazyPreload
  # ActiveRecord::CollectionProxy patch for getting records for preload
  module CollectionProxy
    def preload_associations_lazily
      proxy_association.preloads_associations_lazily = true
      reset_scope
      Context.register_auto_preload(records: target) if loaded?
      self
    end

    private

    def ar_lazy_preload_records
      target
    end
  end
end
