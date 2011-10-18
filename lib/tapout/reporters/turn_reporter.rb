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

      #
      def start_suite(suite)
        @io     = $stdout
        @suite  = suite
        @time   = Time.now
        @stdout = StringIO.new
        @stderr = StringIO.new
        #files = suite.collect{ |s| s.file }.join(' ')
        puts "LOADED SUITE" # #{suite.name}"
        #puts "Started"
      end

      #
      def start_case(kase)
        puts("#{kase['label']}".ansi(:bold))
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

        @stdout.rewind
        @stderr.rewind

        $stdout = @stdout
        $stderr = @stderr unless $DEBUG
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
      def fail(doc)
        message   = doc['exception']['message'].to_s
        backtrace = clean_backtrace(doc['exception']['backtrace'] || [])

        puts(" #{FAIL}")
        puts message.ansi(:bold).tabto(8)

        unless backtrace.empty?
          label = "Assertion at "
          tabsize = 8
          backtrace1 = label + backtrace.shift
          puts(backtrace1.tabto(tabsize))
          if trace = TapOut.trace
            puts backtrace[0,depth].map{|l| l.tabto(label.length + tabsize) }.join("\n")
          end
        end
        show_captured_output
      end

      # TODO: TAP-Y/J needs a field for the error class
      def error(doc)
        exception_class = doc['exception']['class'].to_s
        message         = doc['exception']['message'].to_s.ansi(:bold)
        backtrace       = "Exception `#{exception_class}' at " +
                          clean_backtrace(doc['exception']['backtrace'] || []).join("\n")

        puts("#{ERROR}")
        puts(message.tabto(8))
        puts "STDERR:".tabto(8)
        puts(backtrace.tabto(8))

        show_captured_output
      end

      #
      def finish_test(test)
        $stdout = STDOUT
        $stderr = STDERR
      end

      #
      def show_captured_output
        show_captured_stdout
        #show_captured_stderr
      end

      #
      def show_captured_stdout
        @stdout.rewind
        return if @stdout.eof?
        STDOUT.puts(<<-output.tabto(8))
  \nSTDOUT:
  #{@stdout.read}
        output
      end

# No longer used b/c of error messages are fairly extraneous.
=begin
    def show_captured_stderr
      @stderr.rewind
      return if @stderr.eof?
      STDOUT.puts(<<-output.tabto(8))
\nSTDERR:
#{@stderr.read}
      output
    end
=end

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

      #
      def puts(str)
        @io.puts(str)
      end

      #
      def print(str)
        @io.print(str)
      end

    end

  end

end
