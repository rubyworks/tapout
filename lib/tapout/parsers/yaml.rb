require 'tapout/parsers/abstract'
require 'tapout/reporters'
require 'yaml'

module Tapout

  # The TAP-Y Parser takes a TAP-Y stream and routes it through
  # a tapout report format.
  #
  class YamlParser < AbstractParser

    #
    def initialize(options={})
      format    = options[:format]
      @reporter = Reporters.factory(format).new
      @input    = options[:input] || $stdin
    end

    # Read from input using `gets` and parse, routing
    # entries to reporter.
    #
    # input - Input channel, defaults to $stdin. [#gets]
    #
    # Returns reporter exit code.
    def consume(input=nil)
      @input = input if input

      entry = ''
      while line = @input.gets
        case line
        when EXIT_CODE, /^\.\.\./
          handle(entry)
          entry = passthru
        when RETURN_CODE, /^\-\-\-/
          handle(entry)
          entry = line
        else
          entry << line
        end
      end
      handle(entry)  # in case final `...` was left out

      @reporter.finalize  #@reporter.exit_code
    end

    # Alias for consume.
    alias read consume

    #def <<(line)
    #  case line
    #  when /^\-\-\-/
    #    handle unless @doc.empty?
    #    @doc << line
    #  when /^\.\.\./
    #    handle #@doc
    #    stop
    #  else
    #    @doc << line
    #  end
    #end

    #
    def handle(entry)
      return if entry.empty?
      return if entry == RETURN_CODE

      begin
        data = YAML.load(entry)
        @reporter << data
      rescue Psych::SyntaxError
        passthru(entry)
      end
    end

    # Alias for handle.
    alias << handle

  end

end
