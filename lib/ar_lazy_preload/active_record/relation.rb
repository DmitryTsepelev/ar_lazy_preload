# frozen_string_literal: true

require "ar_lazy_preload/context"

module ArLazyPreload
  # ActiveRecord::Relation patch with lazy preloading support
  module Relation
    attr_writer :preloads_associations_lazily

    # Enhanced #load method will check if association has not been loaded yet and add a context
    # for lazy preloading to loaded each record
    def load
      need_context = !loaded?
      result = super
      if need_context
        Context.register(
          records: ar_lazy_preload_records,
          association_tree: lazy_preload_values,
          auto_preload: preloads_associations_lazily?
        )
      end
      result
    end

    # Lazily autoloads all associations. For example:
    #
    #   users = User.preload_associations_lazily
    #   users.each do |user|
    #     user.posts.flat_map {|post| post.comments.map(&:id)}
    #   end
    #
    # Same effect can be achieved by User.lazy_preload(posts: :comments)
    def preload_associations_lazily
      spawn.tap { |relation| relation.preloads_associations_lazily = true }
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
      args.flatten!
      self.lazy_preload_values += args
      self
    end

    def lazy_preload_values
      @lazy_preload_values ||= []
    end

    private

    def ar_lazy_preload_records
      @records
    end

    def preloads_associations_lazily?
      @preloads_associations_lazily ||= false
    end

    attr_writer :lazy_preload_values
  end
end
