require 'koax/reporters'

require 'yaml'

module Koax

  # The TAP-Y Parser takes a TAP-Y stream and routes it though a Koax
  # report format.
  class TAPYParser

    #
    def initialize(options={})
      format    = options[:format] || 'dotprogress'
      @reporter = Reporters.factory(format).new
      @doc      = ''
      @done = false
    end

    #
    def consume(input)
      @doc  = ''
      @done = false
      while line = input.gets
        self << line
      end
      handle unless @done   # in case `...` was left out
    end

    # TODO: write this as a YAML stream parser
    def <<(line)
      case line
      when /^\-\-\-/
        handle #@doc
        @doc << line
      when /^\.\.\./
        handle #@doc
        stop
      else
        @doc << line
      end
    end

    #
    def handle
      return if @doc == ''
      entry = YAML.load(@doc)
      @reporter << entry
      @doc = ''
    end

    #
    def stop
      @done = true
    end

  end

end
