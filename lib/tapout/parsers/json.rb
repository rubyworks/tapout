require 'tapout/reporters'
require 'json'

module Tapout

  # The TAP-J Parser takes a TAP-J stream and routes it through
  # a TapOut report format.
  #
  class JsonParser

    #
    def initialize(options={})
      format    = options[:format]
      @reporter = Reporters.factory(format).new
    end

    #
    def consume(input)
      while line = input.gets
        self << line
      end
      @reporter.finalize
    end

    #
    def <<(line)
      handle(line)
    end

    #
    def handle(doc)
      return if doc == ''
      entry = JSON.load(doc)
      @reporter << entry
    end

  end

end
