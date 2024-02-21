# frozen_string_literal: true

ENV["RAILS_ENV"] = "test"

if ENV["COVERALLS"]
  require "simplecov"
  require "simplecov-lcov"

  SimpleCov::Formatter::LcovFormatter.config do |c|
    c.report_with_single_file = true
    c.single_report_path = "coverage/lcov.info"
  end

  SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new(
    [SimpleCov::Formatter::HTMLFormatter, SimpleCov::Formatter::LcovFormatter]
  )

  SimpleCov.start do
    add_filter "spec/"
  end
end

require "active_record"
require "db_query_matchers"
require "database_cleaner"
require "factory_bot"

if ENV.fetch("RACK", "false").downcase.strip == "true"
  require_relative "dummy_rack/setup"
else
  require_relative "dummy_rails/config/environment"
end

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
    if ActiveRecord::Base.connection.respond_to?(:materialize_transactions)
      ActiveRecord::Base.connection.disable_lazy_transactions!
    end

    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning { example.run }
  end

  config.before(:all) do
    DatabaseCleaner.start
  end

  config.after(:all) do
    DatabaseCleaner.clean
  end

  config.after(:each) do
    if ArLazyPreload.instance_variable_defined?(:@config)
      ArLazyPreload.remove_instance_variable(:@config)
    end
  end
end

RSpec.shared_examples "check initial loading" do
  it "does not load association before it's called" do
    expect { subject.inspect }.to make_database_queries(count: 1)
  end
end

DBQueryMatchers.configure do |config|
  config.ignores = [/sqlite_master/, /table_info/]
end

ActiveRecord::Base.establish_connection(
  adapter: "sqlite3",
  database: ":memory:"
)

load File.dirname(__FILE__) + "/helpers/schema.rb"
require File.dirname(__FILE__) + "/helpers/models.rb"
require File.dirname(__FILE__) + "/helpers/factories.rb"

ActiveRecord::Base.logger = Logger.new($stdout) if ENV["SQL"]
