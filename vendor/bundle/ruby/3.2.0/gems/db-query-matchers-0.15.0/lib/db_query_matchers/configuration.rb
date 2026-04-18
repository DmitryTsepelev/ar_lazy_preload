module DBQueryMatchers
  # Configuration for the DBQueryMatcher module.
  class Configuration
    attr_accessor :ignores, :ignore_cached, :on_query_counted, :schemaless, :log_backtrace, :backtrace_filter, :db_event

    def initialize
      @db_event = "sql.active_record"
      @ignores = []
      @on_query_counted = Proc.new { }
      @schemaless = false
      @ignore_cached = false
      @log_backtrace = false
      @backtrace_filter = Proc.new { |backtrace| backtrace }
    end
  end
end
