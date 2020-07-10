# frozen_string_literal: true

module ArLazyPreload
  # ActiveRecord::Relation::Merger patch implementing merge functionality
  # for lazy preloadable relations
  module Merger
    # Enhanced #merge implements merging lazy_preload_values
    def merge
      result = super

      if other.lazy_preload_values.any?
        if other.klass == relation.klass
          merge_lazy_preloads
        else
          reflect_and_merge_lazy_preloads
        end
      end

      result
    end

    private

    def merge_lazy_preloads
      relation.lazy_preload!(*other.lazy_preload_values)
    end

    def reflect_and_merge_lazy_preloads
      reflection = relation.klass.reflect_on_all_associations.find do |r|
        r.class_name == other.klass.name
      end
      return unless reflection

      relation.lazy_preload!(reflection.name => other.lazy_preload_values)
    end
  end
end
