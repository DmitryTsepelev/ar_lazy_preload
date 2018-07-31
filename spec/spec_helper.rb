# frozen_string_literal: true

require "coveralls"
Coveralls.wear!

require "active_record"
require "db_query_matchers"
require "database_cleaner"
require "factory_bot"
require "ar_lazy_preload"

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  config.order = :random

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.formatter = :documentation
  config.color = true

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning { example.run }
  end
end

RSpec.shared_examples "check initial loading" do
  it "does not load association before it's called" do
    expect { subject.inspect }.to make_database_queries(count: 1)
  end
end

ActiveRecord::Base.establish_connection(
  adapter: "sqlite3",
  database: ":memory:"
)

load File.dirname(__FILE__) + "/helpers/schema.rb"
require File.dirname(__FILE__) + "/helpers/models.rb"
require File.dirname(__FILE__) + "/helpers/factories.rb"

ActiveRecord::Base.logger = Logger.new(STDOUT) if ENV["SQL"]
