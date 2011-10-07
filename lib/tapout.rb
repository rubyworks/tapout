require 'optparse'
require 'tapout/parsers'

module TapOut

  # Usable formats.
  FORMATS = %w{breakdown dotprogress html outline progressbar tap}

  #
  def self.cli(*argv)
    options = {}
    type    = :modern

    parser = OptionParser.new do |opt|
      opt.banner = "tapout [options] [format]"

      opt.separator("\nOPTIONS:")

      #opt.on('--format', '-f FORMAT', 'Report format') do |fmt|
      #  options[:format] = fmt
      #end

      #opt.on('-t', '--tap', 'Consume legacy TAP input') do |fmt|
      #  type = :legacy
      #end

      opt.on('--no-color', 'Supress ANSI color codes') do
        $ansi = false  # TODO: Is this correct?
      end

      opt.on('--debug', 'Run with $DEBUG flag on') do |fmt|
        $DEBUG = true
      end

      opt.separator("\nFORMATS:\n        " + FORMATS.join("\n        "))
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
      stream_parser.consume(stdin)
    when :yaml
      stream_parser = YamlParser.new(options)
      stream_parser.consume(stdin)
    when :json
      stream_parser = JsonParser.new(options)
      stream_parser.consume(stdin)
    end
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
