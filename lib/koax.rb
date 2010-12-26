require 'koax/tapy_parser'
require 'koax/tap_parser'

require 'optparse'

module Koax

  #
  def self.cli(*argv)
    options = {}
    legacy  = false

    parser = OptionParser.new do |opt|
      opt.on('--format', '-f FORMAT', 'Report format') do |fmt|
        options[:format] = fmt
      end

      opt.on('-t', '--tap', 'Consume legacy TAP input') do |fmt|
        legacy = true
      end

      opt.on('--debug', 'Run with $DEBUG flag on') do |fmt|
        $DEBUG = true
      end
    end

    parser.parse!(argv)

    if legacy
      parser = TAPParser.new(options)
    else
      parser = TAPYParser.new(options)
    end

    parser.consume($stdin)
  end

end
