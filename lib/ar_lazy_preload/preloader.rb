# frozen_string_literal: true

module ArLazyPreload
  class Preloader
    def initialize(records, associations)
      @records = records
      @associations = associations
    end

    class << self
      def patch_for_rails_7!
        define_method(:preload) do
          ActiveRecord::Associations::Preloader.new(
            records: @records, associations: @associations
          ).call
        end
      end
    end

    def preload
      ActiveRecord::Associations::Preloader.new.preload(@records, @associations)
    end
  end
end
