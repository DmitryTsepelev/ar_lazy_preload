# frozen_string_literal: true

module ArLazyPreload
  # ActiveRecord::Association patch with a hook for lazy preloading
  module Association
    def load_target
      owner.try_preload_lazily(reflection.name)
      super
    end

    # rubocop:disable Metrics/AbcSize
    def ids_reader
      return super if owner.lazy_preload_context.blank?

      primary_key = reflection.association_primary_key.to_sym
      if loaded?
        target.map(&primary_key)
      elsif !target.empty?
        load_target.map(&primary_key)
      else
        @association_ids ||= reader.map(&primary_key)
      end
    end
    # rubocop:enable Metrics/AbcSize
  end
end
