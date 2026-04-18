require 'rspec/expectations'

# Custom matcher to check for database queries performed by a block of code.
#
# @example
#   expect { subject }.to_not make_database_queries
#
# @example
#   expect { subject }.to make_database_queries(count: 1)
#
# @example
#   expect { subject }.to make_database_queries(manipulative: true)
#
# @example
#   expect { subject }.to make_database_queries(unscoped: true)
#
# @see DBQueryMatchers::QueryCounter
RSpec::Matchers.define :make_database_queries do |options = {}|
  if RSpec::Core::Version::STRING =~ /^2/
    def self.failure_message_when_negated(&block)
      failure_message_for_should_not(&block)
    end

    def self.failure_message(&block)
      failure_message_for_should(&block)
    end

    def supports_block_expectations?
      true
    end
  else
    supports_block_expectations
  end

  # Taken from ActionView::Helpers::TextHelper
  def pluralize(count, singular, plural = nil)
    word = if count == 1 || count.to_s =~ /^1(\.0+)?$/
             singular
           else
             plural || singular.pluralize
           end

    "#{count || 0} #{word}"
  end

  define_method :matches? do |block|
    counter_options = {}
    if options[:manipulative]
      counter_options[:matches] = [/^\ *(INSERT|UPDATE|DELETE\ FROM)/]
    end
    if options[:unscoped]
      counter_options[:matches] = [
        %r{
          (?:                         # Any of these appear
            SELECT(?!\sCOUNT).*FROM|  #   SELECT ... FROM (not SELECT ... COUNT)
            DELETE\sFROM|             #   DELETE ... FROM
            UPDATE.*SET               #   UPDATE ... SET
          )
          (?!.*(WHERE|LIMIT))         # Followed by WHERE and/or LIMIT
        }mx                           # Ignore whitespace and newlines
      ]
    end
    if options[:matching]
      counter_options[:matches] ||= []
      case options[:matching]
      when Regexp
        counter_options[:matches] << options[:matching]
      when String
        counter_options[:matches] << Regexp.new(Regexp.escape(options[:matching]))
      end
    end

    counter_options[:database_role] = options[:database_role]
    @counter = DBQueryMatchers::QueryCounter.new(counter_options)
    ActiveSupport::Notifications.subscribed(@counter.to_proc,
                                            DBQueryMatchers.configuration.db_event,
                                            &block)
    if absolute_count = options[:count]
      absolute_count === @counter.count
    else
      @counter.count > 0
    end
  end

  failure_message_when_negated do |_|
    <<-EOS
expected no queries, but #{@counter.count} were made:
#{@counter.log.join("\n")}
    EOS
  end

  failure_message do |_|
    if options[:count]
      expected = pluralize(options[:count], 'query')
      actual   = pluralize(@counter.count, 'was', 'were')

      output   = "expected #{expected}, but #{actual} made"
      if @counter.count > 0
        output += ":\n#{@counter.log.join("\n")}"
      end
      output
    else
      'expected queries, but none were made'
    end
  end
end
