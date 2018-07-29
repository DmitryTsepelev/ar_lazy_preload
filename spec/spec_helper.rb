# frozen_string_literal: true

require "coveralls"
Coveralls.wear!

require "active_record"
require "db_query_matchers"
require "ar_lazy_preload"

RSpec.configure do |config|
  config.order = :random

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.formatter = :documentation
  config.color = true
end

ActiveRecord::Base.establish_connection(
  adapter: "sqlite3",
  database: ":memory:"
)

load File.dirname(__FILE__) + "/schema.rb"
require File.dirname(__FILE__) + "/models.rb"

ActiveRecord::Base.logger = Logger.new(STDOUT) if ENV["SQL"]
