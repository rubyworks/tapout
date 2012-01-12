require 'tapout/core_ext'
require 'tapout/reporters/abstract'

module TapOut

  module Reporters

    # = Pretty Reporter (by Paydro)
    #
    class PrettyReporter < Abstract

      #
      PADDING_SIZE = 4

      PASS  = "PASS".ansi(:green)
      FAIL  = "FAIL".ansi(:red)
      ERROR = "ERROR".ansi(:yellow)

      #
      def start_suite(suite)
        #old_sync, @@out.sync = @@out.sync, true if io.respond_to? :sync=
        @suite  = suite
        @time   = Time.now
        #@stdout = StringIO.new
        #@stderr = StringIO.new
        #files = suite.collect{ |s| s.file }.join(' ')
      #puts "Loaded suite #{suite.name}"
        puts "Suite seed: #{suite['seed']}" if suite['seed']
        puts "Started"
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
        print pad_with_size("#{PASS}")
        print " #{test['label']}"
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
      def fail(test)
        print pad_with_size("#{FAIL}")
        print " #{test['label']}"
        print " (%.2fs) " % (Time.now - @test_time)

        #message = assertion.location[0] + "\n" + assertion.message #.gsub("\n","\n")
        #trace   = MiniTest::filter_backtrace(report[:exception].backtrace).first

        message = test['exception']['message']

        if bt = test['exception']['backtrace']
          _trace = clean_backtrace(bt)
        else
          _trace = []
        end

        trace   = _trace.shift
        depth   = TapOut.trace || trace.size
        tabsize = 10

        puts
        #puts pad(message, tabsize)
        puts message.tabto(tabsize)
        puts trace.tabto(tabsize)
        puts _trace[0,depth].map{|l| l.tabto(tabsize) }.join("\n")

        print captured_output(test).tabto(tabsize)
      end

      #
      def error(test)
        print pad_with_size("#{ERROR}")
        print " #{test['label']}"
        print " (%.2fs) " % (Time.now - @test_time)

        #message = exception.to_s.split("\n")[2..-1].join("\n")

        message = test['exception']['message']

        if bt = test['exception']['backtrace']
          _trace = clean_backtrace(bt)
        else
          _trace = filter_backtrace(bt)
        end

        trace   = _trace.shift
        depth   = TapOut.trace || trace.size
        tabsize = 10

        puts
        puts message.tabto(tabsize)
        puts trace.tabto(tabsize)
        puts _trace[0,depth].map{|l| l.tabto(tabsize) }.join("\n")

        print captured_output(test).tabto(tabsize)
      end

      # TODO: skip support
      #def skip
      #  puts(pad_with_size("#{SKIP}"))
      #end

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

        total   = final['counts']['total'] || 0
        failure = final['counts']['fail']  || 0
        error   = final['counts']['error'] || 0
        skip    = final['counts']['todo']  || 0
        omit    = final['counts']['omit']  || 0
        #pass    = total - failure - error

        puts
        puts "Finished in #{'%.6f' % (Time.now - @time)} seconds."
        puts

        print "%d tests, " % total
        #print "%d assertions, " % suite.count_assertions
        print ("%d failures" % failure).ansi(:red) + ', '
        print ("%d errors" % error).ansi(:yellow) + ', '
        print ("%d pending" % skip).ansi(:cyan)
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

