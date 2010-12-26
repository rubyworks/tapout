require 'koax/reporters/abstract'

require 'ansi/progressbar'

module Koax

  module Reporters

    # The progressbar report format utilises a progress bar to indicate
    # elapsed progress.
    class Progressbar < Abstract

      def start_suite(entry)
        @pbar = ::ANSI::Progressbar.new('Testing', entry['count'])
        @pbar.inc
      end

      def start_case(entry)
      end

      def test(entry)
        @pbar.inc
      end

      #def pass(message=nil)
      #  #@pbar.inc
      #end

      #def fail(message=nil)
      #  #@pbar.inc
      #end

      #def error(message=nil)
      #  #@pbar.inc
      #end

      #def finish_case(kase)
      #end

      def finish_suite(entry)
        @pbar.finish
        post_report(entry)
      end

      #
      def post_report(entry)
=begin
        tally = test_tally(entry)

        width = suite.collect{ |tr| tr.name.size }.max

        headers = [ 'TESTCASE  ', '  TESTS   ', 'ASSERTIONS', ' FAILURES ', '  ERRORS   ' ]
        io.puts "\n%-#{width}s       %10s %10s %10s %10s\n" % headers

        files = nil

        suite.each do |testrun|
          if testrun.files != [testrun.name] && testrun.files != files
            label = testrun.files.join(' ')
            label = Colorize.magenta(label)
            io.puts(label + "\n")
            files = testrun.files
          end
          io.puts paint_line(testrun, width)
        end

        #puts("\n%i tests, %i assertions, %i failures, %i errors\n\n" % tally)

        tally_line = "-----\n"
        tally_line << "%-#{width}s  " % "TOTAL"
        tally_line << "%10s %10s %10s %10s" % tally

        io.puts(tally_line + "\n")
=end

        bad = @failed + @raised

        #fails = suite.select do |testrun|
        #  testrun.fail? || testrun.error?
        #end

        #if tally[2] != 0 or tally[3] != 0
          unless bad.empty? # or verbose?
            #puts "\n-- Failures and Errors --\n"
            puts
            bad.each do |e|
              message = e['message'].strip
              message = message.ansi(:red)
              puts(message)
              puts "#{e['file']}:#{e['line']}"
              puts
              puts code_snippet(e)
            end
            puts
          end
        #end

        puts tally(entry)
      end

    private

      def paint_line(testrun, width)
        line = ''
        line << "%-#{width}s  " % [testrun.name]
        line << "%10s %10s %10s %10s" % testrun.counts
        line << " " * 8
        if testrun.fail?
          line << "[#{FAIL}]"
        elsif testrun.error?
          line << "[#{FAIL}]"
        else
          line << "[#{PASS}]"
        end
        line
      end

      def test_tally(suite)
        counts = suite.collect{ |tr| tr.counts }
        tally  = [0,0,0,0]
        counts.each do |count|
          4.times{ |i| tally[i] += count[i] }
        end
        return tally
      end

    end

  end

end

