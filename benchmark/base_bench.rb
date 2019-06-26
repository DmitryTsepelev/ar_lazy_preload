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

class BaseBench
  def run
    raise NotImplementedError
  end

  protected

  # From https://stackoverflow.com/a/20640938/838346
  def without_gc
    GC.start # start out clean
    GC.disable
    yield
    GC.enable
  end

  def setup_data
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
  end
end
