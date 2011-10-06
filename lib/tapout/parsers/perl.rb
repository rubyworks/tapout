require 'tapout/version'
require 'tapout/perl_adapter'
require 'tapout/reporters'

module TapOut

  # The TAPLegacy Parser takes a traditional TAP stream and routes
  # it through a Tap Out report format.
  class perlParser

    # options[:format] - the report format to use
    def initialize(options={})
      format    = options[:format] || 'dotprogress'
      @reporter = Reporters.factory(format).new
    end

    # input - any object that responds to #gets
    def consume(input)
      parser = PerlAdapter.new(input)
      parser | @reporter
    end

  end

end
