require 'koax/version'
require 'koax/tap_legacy_adapter'
require 'koax/reporters'

module Koax

  # The TAPLegacy Parser takes a traditional TAP stream and routes
  # it through a Koax report format.
  class TAPLegacyParser

    # options[:format] - the report format to use
    def initialize(options={})
      format    = options[:format] || 'dotprogress'
      @reporter = Reporters.factory(format).new
    end

    # input - any object that responds to #gets
    def consume(input)
      parser = TAPLegacyAdapter.new(input)
      parser | @reporter
    end

  end

end
