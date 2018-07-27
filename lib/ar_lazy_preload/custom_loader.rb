# frozen_string_literal: true

module ArLazyPreload
  module CustomLoader
    extend ActiveSupport::Concern

    included do
      alias_method :load_source, :load

      def load
        load_source
        @records.each { |record| define_lazy_preload(record, @records) }
        self
      end

      private

      def define_lazy_preload(record, all_records)
        record.define_singleton_method(:perform_lazy_preloading) do |association_name|
          preloader = ActiveRecord::Associations::Preloader.new
          preloader.preload all_records, association_name
        end
      end
    end
  end
end
