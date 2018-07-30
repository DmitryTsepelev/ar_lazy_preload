# frozen_string_literal: true

require "ar_lazy_preload/context"

module ArLazyPreload
  # ActiveRecord::Relation patch with lazy preloading support
  module Relation
    # Enhanced #load method will check if association has not been loaded yet and add a context
    # for lazy preloading to loaded each record
    def load
      need_context = !loaded?
      old_load_result = super
      setup_lazy_preload_context if need_context
      old_load_result
    end

    # Specify relationships to be loaded lazily when association is loaded for the first time. For
    # example:
    #
    #   users = User.lazy_preload(:posts)
    #   users.each do |user|
    #     user.first_name
    #   end
    #
    # will cause only one SQL request to load users, while
    #
    #   users = User.lazy_preload(:posts)
    #   users.each do |user|
    #     user.posts.map(&:id)
    #   end
    #
    # will make an additional query.
    def lazy_preload(*args)
      check_if_method_has_arguments!(:lazy_preload, args)
      spawn.lazy_preload!(*args)
    end

    def lazy_preload!(*args)
      args.reject!(&:blank?)
      args.flatten!
      self.lazy_preload_values += args
      self
    end

    def lazy_preload_values
      @lazy_preload_values ||= []
    end

    private

    attr_writer :lazy_preload_values

    def setup_lazy_preload_context
      return if lazy_preload_values.blank? || @records.blank?

      ArLazyPreload::Context.new(
        model: model,
        records: @records,
        association_tree: lazy_preload_values
      )
    end
  end
end
