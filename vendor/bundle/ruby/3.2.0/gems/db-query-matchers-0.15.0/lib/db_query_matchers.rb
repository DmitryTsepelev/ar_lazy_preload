require 'db_query_matchers/version'
require 'db_query_matchers/make_database_queries'
require 'db_query_matchers/query_counter'
require 'db_query_matchers/configuration'
require 'active_support'

# Main module that holds global configuration.
module DBQueryMatchers
  class << self
    attr_writer :configuration
  end

  # Gets the current configuration
  # @return [DBQueryMatchers::Configuration] the active configuration
  def self.configuration
    @configuration ||= Configuration.new
  end

  # Resets the current configuration.
  # @return [DBQueryMatchers::Configuration] the active configuration
  def self.reset_configuration
    @configuration = Configuration.new
  end

  # Updates the current configuration.
  # @example
  #   DBQueryMatchers.configure do |config|
  #     config.ignores = [/SELECT.*FROM.*users/]
  #   end
  #
  def self.configure
    yield(configuration)
  end
end
