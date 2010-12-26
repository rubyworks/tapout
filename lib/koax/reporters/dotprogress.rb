require 'koax/reporters/abstract'

module Koax::Reporters

  # Traditional dot progress reporter.
  class Dotprogress < Abstract

    #
    def start_suite(entry)
      @start_time = Time.now
      $stdout.puts "Started\n"
    end

    #
    def pass(entry)
      $stdout.print '.'
      $stdout.flush
      super(entry)
    end

    #
    def fail(entry)
      $stdout.print 'F'.ansi(:red)
      $stdout.flush
      super(entry)
    end

    #
    def err(entry)
      $stdout.print 'E'.ansi(:yellow)
      $stdout.flush
      super(entry)
    end

    #
    def finish_suite(entry)
      $stdout.puts "\n\n"

      i = 1

      @failed.each do |e|
        #backtrace = clean_backtrace(exception.backtrace)
        $stdout.puts "#{i}. " + (e['label']).ansi(:red)
        $stdout.puts
        $stdout.puts "    #{e['message']}"
        $stdout.puts "    #{e['file']}:#{e['line']}" #+ backtrace[0]
        $stdout.puts code_snippet(e)
        $stdout.puts
        i += 1
      end

      @raised.each do |e|
        #backtrace = clean_backtrace(exception.backtrace)
        $stdout.puts "#{i}. " + (e['label']).ansi(:yellow)
        $stdout.puts
        $stdout.puts "    #{e['message']}"
        $stdout.puts "    #{e['file']}:#{e['line']}" #+ backtrace[0..2].join("    \n")
        $stdout.puts code_snippet(e)
        $stdout.puts
        i += 1
      end

      $stdout.puts "Finished in #{Time.now - @start_time}s"
      $stdout.puts tally
    end

  end

end
