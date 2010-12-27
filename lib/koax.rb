require 'koax/tapy_parser'
require 'koax/tap_legacy_parser'

require 'optparse'

module Koax

  #
  def self.cli(*argv)
    options = {}
    type    = :modern

    parser = OptionParser.new do |opt|
      opt.on('--format', '-f FORMAT', 'Report format') do |fmt|
        options[:format] = fmt
      end

      opt.on('-t', '--tap', 'Consume legacy TAP input') do |fmt|
        type = :legacy
      end

      opt.on('--no-color', 'Supress ANSI color codes') do
        # TODO
      end

      opt.on('--debug', 'Run with $DEBUG flag on') do |fmt|
        $DEBUG = true
      end
    end

    parser.parse!(argv)

    # TODO: would be nice if it could automatically determine which
    #line1 = $stdin.readline
    #        $stdin.rewind
    #type = :legacy if line1 =~ /^\d+/
    #type = :modern if line1 =~ /^\-/

    case type
    when :legacy
      stream_parser = TAPLegacyParser.new(options)
      stream_parser.consume($stdin)
    else
      stream_parser = TAPYParser.new(options)
      stream_parser.consume($stdin)
    end

  end

end
