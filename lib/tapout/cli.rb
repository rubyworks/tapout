module Tapout

  require 'optparse'

  # Command line interface.
  #
  def self.cli(*argv)
    options = {}
    type    = :modern

    parser = OptionParser.new do |opt|
      opt.banner = "tapout [options] [reporter]"

      opt.separator("\nOPTIONS:")

      #opt.on('-t', '--tap', 'Consume legacy TAP input') do |fmt|
      #  type = :legacy
      #end

      opt.on('--trace', '-t DEPTH', 'set backtrace depth') do |depth|
        self.config.trace = depth
      end

      opt.on('--lines', '-l LINES', 'number of surrounding source code lines') do |lines|
        self.config.lines = lines.to_i
      end

      opt.on('--minimal', '-m', 'show only errors, failures and pending tests') do |val|
        self.config.minimal = val
      end

      opt.on('--no-color', 'Supress ANSI color codes') do
        $ansi = false
      end

      opt.on('--debug', 'Run with $DEBUG flag on') do |fmt|
        $DEBUG = true
      end

      opt.separator("\nREPORTERS:\n        " + Reporters.index.keys.join("\n        "))
    end

    parser.parse!(argv)

    options[:format] = argv.first

    # TODO: would be nice if it could automatically determine which
    #c = $stdin.getc
    #    $stdin.pos = 0
    #type = :legacy if c =~ /\d/
    #type = :modern if c == '-'

    stdin = Curmudgeon.new($stdin)

    case stdin.line1
    when /^\d/
      type = :perl
    when /^\-/
      type = :yaml
    when /^\{/
      type = :json
    else
      raise "Not a recognized TAP stream!"
    end

    case type
    when :perl
      stream_parser = PerlParser.new(options)
      exit_code     = stream_parser.consume(stdin)
    when :yaml
      stream_parser = YamlParser.new(options)
      exit_code     = stream_parser.consume(stdin)
    when :json
      stream_parser = JsonParser.new(options)
      exit_code     = stream_parser.consume(stdin)
    end

    exit(exit_code || 0)
  end

  #
  class Curmudgeon #< IO
    def initialize(input)
      @input = input
      @line1 = input.gets
    end
    def line1
      @line1
    end
    def gets
      (class << self; self; end).class_eval %{
        def gets; @input.gets; end
      }
      return @line1
    end
  end

end
