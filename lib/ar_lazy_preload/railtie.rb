# frozen_string_literal: true

module ArLazyPreload
  class Railtie < Rails::Railtie
    config.to_prepare do |_app|
      ActiveSupport.on_load(:active_record) do
        ArLazyPreload.install_hooks
      end
    end
  end
end
