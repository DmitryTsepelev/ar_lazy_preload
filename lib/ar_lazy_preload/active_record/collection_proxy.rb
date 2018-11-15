# frozen_string_literal: true

module ArLazyPreload
  # ActiveRecord::CollectionProxy patch for getting records for preload
  module CollectionProxy
    private

    def ar_lazy_preload_records
      target
    end
  end
end
