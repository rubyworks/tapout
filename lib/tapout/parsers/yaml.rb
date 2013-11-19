require 'tapout/parsers/abstract'
require 'tapout/reporters'
require 'yaml'

module Tapout

  # The TAP-Y Parser takes a TAP-Y stream and routes it through
  # a tapout report format.
  #
  class YamlParser < AbstractParser

    NEW_DOCUMENT = /^\-\-\-/
    END_DOCUMENT = /^\.\.\.\s*$/

    #
    def initialize(options={})
      format    = options[:format]
      @reporter = Reporters.factory(format).new
      @input    = options[:input] || $stdin

      @resume = NEW_DOCUMENT
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
        when PAUSE_DOCUMENT
          @resume = RESUME_DOCUMENT
          passthru
        when RESUME_DOCUMENT # (no effect)
        when END_DOCUMENT
          handle(entry)
          @resume = NEW_DOCUMENT
          entry = passthru
        when NEW_DOCUMENT
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

    # Handle document entry.
    #
    # Returns nothing.
    def handle(entry)
      return if entry == RESUME_DOCUMENT

      stripped = entry.strip
      return if stripped.empty?
      return if stripped == "---"

      begin
        data = YAML.load(entry)
        @reporter << data
      rescue Psych::SyntaxError
        passthru(entry)
      end
    end

    # Alias for handle.
    alias << handle

    # Passthru incoming data directly to `$stdout`.
    #
    def passthru(doc=nil)
      $stdout << doc if doc
      while line = @input.gets
        return line if @resume === line
        $stdout << line
      end
      return ''
    end

  end

end
