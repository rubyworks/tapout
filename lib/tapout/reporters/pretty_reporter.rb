require 'tapout/core_ext'
require 'tapout/reporters/abstract'

module Tapout

  module Reporters

    # Pretty Reporter (by Paydro)
    #
    class PrettyReporter < Abstract

      #
      PADDING_SIZE = 4

      PASS  = " PASS".ansi(*Tapout.config.pass)
      TODO  = " TODO".ansi(*Tapout.config.todo)
      OMIT  = " OMIT".ansi(*Tapout.config.omit)
      FAIL  = " FAIL".ansi(*Tapout.config.fail)
      ERROR = "ERROR".ansi(*Tapout.config.error)

      #
      def start_suite(suite)
        super(suite)
        @suite  = suite
        #files = suite.collect{ |s| s.file }.join(' ')
        print "Running Suite"  #{suite.name}
        print " w/ Seed: #{suite['seed']}" if suite['seed']
        puts
      end

      #
      def start_case(kase)
        #if kase.size > 0  # TODO: Don't have size yet?
          print "\n#{kase['label']}:\n"
        #end
      end

      #
      def start_test(test)
        @test_time = Time.now
        @test = test
        #if @file != test.file
        #  @file = test.file
        #  puts(test.file)
        #end
        #print "    %-69s" % test.name
        #$stdout = @stdout
        #$stderr = @stderr
        #$stdout.rewind
        #$stderr.rewind
      end

      #
      def pass(test)
        return if config.minimal?

        label = test['label'].to_s.ansi(*config.highlight)

        print pad_with_size("#{PASS}")
        print " #{label}"
        print " (%.2fs) " % (Time.now - @test_time)

        #if message
        #  message = test['source'].ansi(:magenta)
        #  message = message.to_s.tabto(10)
        #  puts(message)
        #end

        # TODO: Is there any reason to show captured output for passing test?
        #if captured_output?(test)
        #  puts captured_output(test).tabto(tabsize)
        #end
      end

      #
      def todo(test)
        label = test['label'].to_s.ansi(*config.highlight)

        print pad_with_size("#{TODO}")
        print " #{label}"
        print " (%.2fs) " % (Time.now - @test_time)
      end

      #
      def omit(test)
        return if config.minimal?

        label = test['label'].to_s.ansi(*config.highlight)

        print pad_with_size("#{OMIT}")
        print " #{label}"
        print " (%.2fs) " % (Time.now - @test_time)
      end

      #
      def fail(test)
        label = test['label'].to_s.ansi(*config.highlight)

        print pad_with_size("#{FAIL}")
        print " #{label}"
        print " (%.2fs) " % (Time.now - @test_time)

        message = test['exception']['message'].to_s

        tabsize = 10

        puts
        puts message.tabto(tabsize)
        puts backtrace_snippets(test).tabto(tabsize)

        print captured_output(test).tabto(tabsize)
      end

      #
      def error(test)
        label = test['label'].to_s.ansi(*config.highlight)

        print pad_with_size("#{ERROR}")
        print " #{label}"
        print " (%.2fs) " % (Time.now - @test_time)

        message = test['exception']['message'].to_s

        tabsize = 10

        puts
        puts message.tabto(tabsize) unless message.empty?
        puts backtrace_snippets(test).tabto(tabsize)

        print captured_output(test).tabto(tabsize)
      end

      #
      def finish_test(test)
        puts
        #@test_count += 1
        #@assertion_count += inst._assertions
        #$stdout = STDOUT
        #$stderr = STDERR
      end

      #
      def finish_case(kase)
        #if kase.size == 0
        #  puts pad("(No Tests)")
        #end
      end

      #
      def finish_suite(final)
        #@@out.sync = old_sync if @@out.respond_to? :sync=

        total, pass, fail, error, todo, omit = count_tally(final)

        puts
        puts "Finished in #{'%.6f' % (Time.now - @start_time)} seconds."
        puts

        print "%d tests: " % total
        #print "%d assertions, " % suite.count_assertions
        print ("%d failures" % fail).ansi(*config.fail)   + ', '
        print ("%d errors"   % error).ansi(*config.error) + ', '
        print ("%d pending"  % todo).ansi(*config.todo)   + ', '
        print ("%d omitted"  % omit).ansi(*config.omit)
        puts
      end

    private

      #
      def pad(str, size=PADDING_SIZE)
        " " * size + str
      end

      #
      def pad_with_size(str)
        " " * (18 - str.size) + str
      end

    end

  end

end

