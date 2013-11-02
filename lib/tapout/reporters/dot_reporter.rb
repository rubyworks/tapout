require 'tapout/reporters/abstract'

module Tapout::Reporters

  # Traditional dot progress reporter.
  #
  class DotReporter < Abstract

    #
    def start_suite(suite)
      print "Started"
      print " w/ Seed: #{suite['seed']}" if suite['seed']
      puts
      super(suite)
    end

    #
    def pass(entry)
      $stdout.print '.'.ansi(*config.pass)
      $stdout.flush
      super(entry)
    end

    #
    def fail(entry)
      $stdout.print 'F'.ansi(*config.fail)
      $stdout.flush
      super(entry)
    end

    #
    def error(entry)
      $stdout.print 'E'.ansi(*config.error)
      $stdout.flush
      super(entry)
    end

    #
    def finish_suite(entry)
      $stdout.puts "\n\n"

      i = 1

      @failed.each do |test|
        label     = test['label'].to_s
        snippets  = backtrace_snippets(test)
        errclass  = test['exception']['class']
        message   = test['exception']['message']
        capture   = captured_output(test)
 
        parts = [errclass, message, snippets, capture].compact.map{ |e| e.strip }.reject{ |e| e.empty? }

        puts "#{i}. " + "FAIL".ansi(*config.error) + " " + label.ansi(*config.fail)
        puts
        puts parts.join("\n\n").tabto(4)
        puts

        i += 1
      end

      @raised.each do |test|
        label     = test['label'].to_s
        snippets  = backtrace_snippets(test)
        errclass  = test['exception']['class']
        message   = test['exception']['message']
        capture   = captured_output(test)
 
        parts = [errclass, message, snippets, capture].compact.map{ |e| e.strip }.reject{ |e| e.empty? }

        puts "#{i}. " + "ERROR".ansi(*config.error) + " " + label.ansi(*config.highlight)
        puts
        puts parts.join("\n\n").tabto(4)
        puts

        i += 1
      end

      time, rate, avg = time_tally(entry)

      # total, pass, fail, error, todo, omit = count_tally(entry)

      #total = @passed.size + @failed.size + @raised.size + @skipped.size + @omitted.size
      #total = entry['counts']['total'] || total

      #time = (entry['time'] || (Time.now - @start_time)).to_f
      #avg  = time / total
      #rate = total / time

      puts
      puts "Finished in %.3fs (%.3f test/s, %.6fs avg.)" % [time, rate, avg]
      puts
      puts tally_message(entry)
    end

  end

end
