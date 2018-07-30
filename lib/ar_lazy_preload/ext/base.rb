# frozen_string_literal: true

module ArLazyPreload
  # ActiveRecord::Base patch with lazy preloading support
  module Base
    module Delegation
      delegate :lazy_preload, to: :all
    end

    def self.included(base)
      base.extend(Delegation)
    end

    attr_reader :lazy_preload_context

    def lazy_preload_context=(value)
      @lazy_preload_context = value
    end

    def preload_association_for_context(association_name)
      lazy_preload_context.preload_association(association_name) if lazy_preload_context.present?
    end
  end
end
