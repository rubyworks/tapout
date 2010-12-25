require 'ko/reporters/abstract'

module KO::Reporters

  # Traditional dot progress reporter.
  class Dotprogress < Abstract

    #
    def start_suite(suite)
      @start_time = Time.now
      $stdout.puts "Started\n"
    end

    #
    def pass(ok)
      $stdout.print '.'
      $stdout.flush
      super(ok)
    end

    #
    def fail(ok, exception)
      $stdout.print 'F'.ansi(:red)
      $stdout.flush
      super(ok, exception)
    end

    #
    def err(ok, exception)
      $stdout.print 'E'.ansi(:yellow)
      $stdout.flush
      super(ok, exception)
    end

    #
    def finish_suite(suite)
      $stdout.puts "\n\n"

      i = 1

      @failed.each do |(ok, exception)|
        concern  = ok.concern
        #backtrace = clean_backtrace(exception.backtrace)
        $stdout.puts "#{i}. " + (concern.full_label).ansi(:red)
        $stdout.puts
        $stdout.puts "    #{exception}"
        $stdout.puts "    #{ok.file}:#{ok.line}" #+ backtrace[0]
        $stdout.puts code_snippet(ok.file, ok.line)
        $stdout.puts
        i += 1
      end

      @raised.each do |(ok, exception)|
        concern  = ok.concern
        #backtrace = clean_backtrace(exception.backtrace)
        $stdout.puts "#{i}. " + (concern.full_label).ansi(:yellow)
        $stdout.puts
        $stdout.puts "    #{exception.class}: #{exception.message}"
        $stdout.puts "    #{ok.file}:#{ok.line}" #+ backtrace[0..2].join("    \n")
        $stdout.puts code_snippet(ok.file, ok.line)
        $stdout.puts
        i += 1
      end

      $stdout.puts "Finished in #{Time.now - @start_time}s"
      $stdout.puts tally
    end

  end

end
