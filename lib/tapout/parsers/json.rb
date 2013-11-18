require 'tapout/parsers/abstract'
require 'tapout/reporters'
require 'json'

module Tapout

  # The TAP-J Parser takes a TAP-J stream and routes it through
  # a Tapout report format.
  #
  class JsonParser < AbstractParser

    #
    def initialize(options={})
      format    = options[:format]
      @reporter = Reporters.factory(format).new
      @input    = options[:input] || $stdin
    end

    #
    def consume(input=nil)
      @input = input if input

      while line = input.gets
        case line
        when EXIT_CODE
          passthru
        when RETURN_CODE
        else
          handle(line)
        end
      end

      @reporter.finalize
    end

    # Alias for consume.
    alias read consume

    #
    def handle(entry)
      return if entry.empty?
      return if entry == RETURN_CODE

      begin
        data = JSON.load(entry)
        @reporter << data
      rescue JSON::ParserError
        passthru(entry)
      end
    end

    # Alias for handle.
    alias << handle

  end

end
