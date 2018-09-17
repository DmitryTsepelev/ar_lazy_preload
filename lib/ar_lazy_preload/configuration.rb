# frozen_string_literal: true

module ArLazyPreload
  # ArLazyPreload configuration:
  #
  # - `auto_preload` - load all the associations lazily without
  #    an explicit lazy_preload call
  class Configuration
    attr_accessor :auto_preload

    def initialize
      @auto_preload = false
    end

    alias auto_preload? auto_preload
  end
end
