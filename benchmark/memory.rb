# frozen_string_literal: true

$:.push File.expand_path("lib", __dir__)

require "memory_profiler"

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

# From https://stackoverflow.com/a/20640938/838346
def without_gc
  GC.start # start out clean
  GC.disable
  yield
  GC.enable
end

def run_with_memory_report(section_name)
  print "\n"
  print "#{ "-" * section_name.length}\n"
  print "#{section_name.to_s.ljust(50)}\n"
  print "#{ "-" * section_name.length}\n"
  print "\n"

  print(
    MemoryProfiler.report do
      yield
    end.pretty_print,
  )
end

# Setup data
10.times do
  user_1 = User.create!
  user_2 = User.create!
  100.times do
    post_1 = Post.create!(user: user_1)
    post_2 = Post.create!(user: user_2)

    10.times do
      Comment.create!(post: post_1, user: user_2)
      Comment.create!(post: post_2, user: user_1)
    end
  end
end


without_gc do
  run_with_memory_report("AR eager loading w/ 100% usage: ") do
    ::User.all.includes(posts: :comments).map do |user|
      user.posts.to_a.each do |post|
        post.comments.to_a.each {|c| c.id}
      end
    end
  end
end

without_gc do
  run_with_memory_report("AR eager loading w/ 0% usage: ") do
    ::User.all.includes(posts: :comments).map do |user|
      user.id
    end
  end
end

without_gc do
  run_with_memory_report("AR lazy preloading w/o auto_preload w/ 100% usage: ") do
    ArLazyPreload.config.auto_preload = false

    ::User.all.lazy_preload(posts: :comments).map do |user|
      user.posts.to_a.each do |post|
        post.comments.to_a.each {|c| c.id}
      end
    end
  end
end

without_gc do
  run_with_memory_report("AR lazy preloading w/o auto_preload w/ 0% usage: ") do
    ArLazyPreload.config.auto_preload = false

    ::User.all.lazy_preload(posts: :comments).map do |user|
      user.id
    end
  end
end

without_gc do
  run_with_memory_report("AR lazy preloading w/ auto_preload w/ 100% usage: ") do
    ArLazyPreload.config.auto_preload = true

    ::User.all.map do |user|
      user.posts.to_a.each do |post|
        post.comments.to_a.each {|c| c.id}
      end
    end
  end
end

without_gc do
  run_with_memory_report("AR lazy preloading w/ auto_preload w/ 0% usage: ") do
    ArLazyPreload.config.auto_preload = true

    ::User.all.map do |user|
      user.id
    end
  end
end
