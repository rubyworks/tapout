require 'tapout/reporters/abstract'

module TapOut::Reporters

  # Traditional dot progress reporter.
  #
  class DotReporter < Abstract

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
    def error(entry)
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
        $stdout.puts "    #{e['exception']['class']}" if e['exception']['class']
        $stdout.puts "    #{e['exception']['message']}"
        $stdout.puts "    #{e['exception']['file']}:#{e['exception']['line']}" #+ backtrace[0]
        $stdout.puts code_snippet(e['exception'])
        $stdout.puts
        i += 1
      end

      @raised.each do |e|
        #backtrace = clean_backtrace(exception.backtrace)
        $stdout.puts "#{i}. " + (e['label']).ansi(:yellow)
        $stdout.puts
        $stdout.puts "    #{e['exception']['class']}" if e['exception']['class']
        $stdout.puts "    #{e['exception']['message']}"
        $stdout.puts "    #{e['exception']['file']}:#{e['exception']['line']}" #+ backtrace[0..2].join("    \n")
        $stdout.puts code_snippet(e['exception'])
        $stdout.puts
        i += 1
      end

      $stdout.puts "Finished in #{Time.now - @start_time}s"
      $stdout.puts tally_message(entry)
    end

  end

end
