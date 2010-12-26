require 'koax/reporters/abstract'

module Koax::Reporters

  # Verbose reporter.
  class Verbose < Abstract

    #
    def start_suite(entry)
      @start_time = Time.now
    end

    #
    def start_case(entry)
      $stdout.puts entry['label'].ansi(:bold)
    end

    def pass(entry)
      super(entry)
      $stdout.puts "* " + entry['label'].ansi(:green) + "   #{entry['source']}"
    end

    def fail(entry)
      super(entry)
      $stdout.puts "* " + entry['label'].ansi(:red) + "   #{entry['source']}"
      $stdout.puts
      $stdout.puts "    #{entry['message']}"
      #$stdout.puts "    " + ok.caller #clean_backtrace(exception.backtrace)[0]
      $stdout.puts
      $stdout.puts code_snippet(entry)
      $stdout.puts
    end

    def err(entry)
      super(entry)
      $stdout.puts "* " + entry['label'].ansi(:yellow) + "   #{entry['source']}"
      $stdout.puts
      $stdout.puts "    #{entry['message']}"  # error class?
      #$stdout.puts "    " + ok.caller #clean_backtrace(exception.backtrace)[0..2].join("    \n")
      $stdout.puts
      $stdout.puts code_snippet(entry)
      $stdout.puts
    end

    #
    def finish_suite(entry)
      #$stderr.puts
      $stdout.print tally(entry)
      $stdout.puts " [%0.4fs] " % [Time.now - @start_time]
    end

  end

end
