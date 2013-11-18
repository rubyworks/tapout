require 'tapout/version'
require 'tapout/adapters/perl'
require 'tapout/reporters'
require 'tapout/parsers/abstract'

module Tapout

  # This legacy parser takes a traditional TAP stream and routes
  # it through a Tapout report format.
  class PerlParser < AbstractParser

    # options[:format] - the report format to use
    def initialize(options={})
      format    = options[:format]
      @reporter = Reporters.factory(format).new
    end

    # input - any object that responds to #gets
    def consume(input)
      parser = PerlAdapter.new(input)
      parser | @reporter
      return @reporter.exit_code
    end

  end

end
