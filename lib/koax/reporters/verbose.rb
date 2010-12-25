require 'ko/reporters/abstract'

module KO::Reporters

  # Verbose reporter.
  class Verbose < Abstract

    #
    def start_suite(suite)
      @start_time = Time.now
    end

    #
    def start_concern(concern)
      $stdout.puts concern.to_s.ansi(:bold)
    end

    def pass(ok)
      super(ok)
      $stdout.puts "* " + ok.check.to_s.ansi(:green) + " #{ok}"
    end

    def fail(ok, exception)
      super(ok, exception)
      concern = ok.concern
      $stdout.puts "* " + ok.check.to_s.ansi(:red) + " #{ok}"
      $stdout.puts
      $stdout.puts "    #{exception}"
      $stdout.puts "    " + ok.caller #clean_backtrace(exception.backtrace)[0]
      $stdout.puts
      $stdout.puts code_snippet(ok.file, ok.line)
      $stdout.puts
    end

    def err(ok, exception)
      super(ok, exception)
      concern = ok.concern
      $stdout.puts "* " + ok.check.to_s.ansi(:yellow) + " #{ok}"
      $stdout.puts
      $stdout.puts "    #{exception.class}: #{exception.message}"
      $stdout.puts "    " + ok.caller #clean_backtrace(exception.backtrace)[0..2].join("    \n")
      $stdout.puts
      $stdout.puts code_snippet(ok.file, ok.line)
      $stdout.puts
    end

    #
    def finish_suite(suite)
      #$stderr.puts
      $stderr.print tally
      $stderr.puts " [%0.4fs] " % [Time.now - @start_time]
    end

  end

end
