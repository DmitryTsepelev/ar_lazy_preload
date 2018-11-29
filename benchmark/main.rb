# frozen_string_literal: true

$:.push File.expand_path("lib", __dir__)

require "benchmark"
require "benchmark/ips"

ENV["RAILS_ENV"] = "test"

require_relative "./../spec/dummy/config/environment"

require "active_record"
require "ar_lazy_preload"

ActiveRecord::Base.establish_connection(
  adapter: "sqlite3",
  database: ":memory:"
)

require_relative "./../spec/helpers/schema"
require_relative "./../spec/helpers/models"

# Setup data
user_1 = User.create!
user_2 = User.create!
100.times do
  post_1 = Post.create!(user: user_1)
  post_2 = Post.create!(user: user_2)

  100.times do
    Comment.create!(post: post_1, user: user_2)
    Comment.create!(post: post_2, user: user_1)
  end
end

Benchmark.bm(40) do |x|
  # Use AR's eager loading
  x.report("AR eager loading: ") do
    ::User.all.includes(posts: :comments).map do |user|
      user.posts.to_a.each do |post|
        post.comments.to_a.each {|c| c.id}
      end
    end
  end

  # Use ar_lazy_preload
  x.report("AR lazy preloading w/o auto_preload: ") do
    ArLazyPreload.config.auto_preload = false

    ::User.all.lazy_preload(posts: :comments).map do |user|
      user.posts.to_a.each do |post|
        post.comments.to_a.each {|c| c.id}
      end
    end
  end

  # Use ar_lazy_preload
  x.report("AR lazy preloading w/ auto_preload: ") do
    ArLazyPreload.config.auto_preload = true

    ::User.all.lazy_preload(posts: :comments).map do |user|
      user.posts.to_a.each do |post|
        post.comments.to_a.each {|c| c.id}
      end
    end
  end
end
