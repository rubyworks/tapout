require 'tapout/reporters/abstract'
require 'stringio'

module TapOut

  module Reporters

    # The test report format made famous by Tim Piece and his Turn project.
    #
    #--
    # TODO: Should we fit reporter output to width of console?
    # TODO: Running percentages?
    #++
    class TurnReporter < Abstract #Reporter

      PASS  = "PASS".ansi(:green)
      FAIL  = "FAIL".ansi(:red)
      ERROR = "ERROR".ansi(:yellow)
      TODO  = "TODO".ansi(:magenta)

      #
      def start_suite(suite)
        #@io     = $stdout
        @suite  = suite
        @time   = Time.now
        #files = suite.collect{ |s| s.file }.join(' ')
        puts "LOADED SUITE" # #{suite.name}"
        #puts "Started"
      end

      #
      def start_case(testcase)
        puts("#{testcase['label']}".ansi(:bold))
      end

      #
      def start_test(test)
        #if @file != test.file
        #  @file = test.file
        #  puts(test.file)
        #end

        name = if @natural
                 " #{test['label'].gsub("test_", "").gsub(/_/, " ")}" 
               else
                 " #{test['label']}"
               end

        print "    %-69s" % name
      end

      #
      def pass(doc)
        puts " #{PASS}"
        #if message
        #  message = Colorize.magenta(message)
        #  message = message.to_s.tabto(8)
        #  puts(message)
        #end
      end

      #
      def todo(doc)
        puts " #{TODO}"
        #if message
        #  message = Colorize.magenta(message)
        #  message = message.to_s.tabto(8)
        #  puts(message)
        #end
      end

      #
      #
      def fail(doc)
        message   = doc['exception']['message'].to_s
        backtrace = clean_backtrace(doc['exception']['backtrace'] || [])
        depth     = TapOut.trace || backtrace.size

        puts(" #{FAIL}")
        puts message.ansi(:bold).tabto(8)
        puts(captured_output(doc).strip.tabto(8)) if captured_output?(doc)
        unless backtrace.empty?
          label = "Assertion at "
          tabsize = 8
          str = (label + backtrace.shift).tabto(tabsize)
          str << backtrace[0,depth].map{|l| l.tabto(label.length + tabsize) }.join("\n")
          #puts(backtrace1.tabto(tabsize))
          puts str.rstrip
        end
      end

      #
      #
      def error(doc)
        exception_class = doc['exception']['class'].to_s
        message         = doc['exception']['message'].to_s.ansi(:bold)

        backtrace       = clean_backtrace(doc['exception']['backtrace'] || [])
        depth           = TapOut.trace || backtrace.size
        backtrace       = "Exception `#{exception_class}' at " + backtrace[0,depth].join("\n")

        puts("#{ERROR}")
        puts(message.tabto(8))
        puts(captured_output(doc).strip.tabto(8)) if captured_output?(doc)
        puts(backtrace.strip.tabto(8))
      end

      #
      #def finish_test(test)
      #end

      #
      #def finish_case(kase)
      #end

      #
      def finish_suite(suite)
        total   = suite['counts']['total']
        pass    = suite['counts']['pass']
        failure = suite['counts']['fail']
        error   = suite['counts']['error']
        #pass    = total - failure - error

        bar = '=' * 78
        if $ansi
          bar = if pass == total then bar.ansi(:green)
                else bar.ansi(:red) end
        end

        #tally = [total, suite.count_assertions]
        tally = [total]

        puts bar
        puts "  pass: %d,  fail: %d,  error: %d" % [pass, failure, error]
        #puts "  total: %d tests with %d assertions in #{Time.new - @time} seconds" % tally
        puts "  total: %d tests in #{Time.new - @time} seconds" % tally
        puts bar
      end

    end

  end

end
