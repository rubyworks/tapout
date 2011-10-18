require 'tapout/reporters'
require 'yaml'

module TapOut

  # The TAP-Y Parser takes a TAP-Y stream and routes it through
  # a TapOut report format.
  class YamlParser

    #
    def initialize(options={})
      format    = options[:format]
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
      return @reporter.exit_code
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
