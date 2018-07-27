# frozen_string_literal: true

module ArLazyPreload
  module Base
    extend ActiveSupport::Concern

    module ClassMethods
      delegate :lazy_preload, to: :all
    end
  end
end
