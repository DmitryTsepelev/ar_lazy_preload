# frozen_string_literal: true

require "ar_lazy_preload/configuration"
require "ar_lazy_preload/railtie"

module ArLazyPreload
  class << self
    def config
      @config ||= Configuration.new
    end
  end
end
