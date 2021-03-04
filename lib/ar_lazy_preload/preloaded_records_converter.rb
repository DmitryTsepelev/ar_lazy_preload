# frozen_string_literal: true

module ArLazyPreload
  class PreloadedRecordsConverter
    # For different versions of rails we have different records class
    # for ~> 6.1.0 it returns plain array
    # for ~> 6.0.0 it returns ActiveRecord::Relation
    def self.call(preloaded_records)
      case preloaded_records
      when Array
        preloaded_records
      when ::ActiveRecord::Relation
        raise(ArgumentError, "The relation is not preloaded") unless preloaded_records.loaded?

        preloaded_records.to_a
      else
        raise(ArgumentError, "Unsupported class for preloaded records")
      end
    end
  end
end
