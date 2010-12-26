require 'koax/reporters/abstract'

module Koax

  module Reporters

    # The Breakdown report format give a tally for each test case.
    class Breakdown < Abstract

      def initialize
        super
        @case = {}
        @case_entries = []
      end

      def start_suite(entry)
        headers = [ 'TESTCASE', 'TESTS', 'PASS', 'FAIL', 'ERR', 'SKIP' ]
        puts "\n%-20s       %8s %8s %8s %8s %8s\n" % headers
      end

      def start_case(entry)
        @case = entry
        @case_entries = []
      end

      def test(entry)
        @case_entries << entry
      end

      #
      def finish_case(entry)
        label  = entry['label'][0,19]
        groups = @case_entries.group_by{ |e| e['status'] }

        total = @case_entries.size
        sums  = %w{pass fail error pending}.map{ |n| groups[n] ? groups[n].size : 0 }

        result = sums[1] + sums[2] > 0 ? "FAIL".ansi(:red) : "PASS".ansi(:green)

        puts "%-20s      %8s %8s %8s %8s %8s    [%s]" % ([label, total] + sums + [result])
      end

      #
      def finish_suite(entry)
        #@pbar.finish
        post_report(entry)
      end

      #
      def post_report(entry)

        sums = %w{pass fail error pending}.map{ |n| entry['tally'][n] || 0 }

        puts ("-" * 80)

        tally_line = "%-20s      " % "TOTAL"
        tally_line << "%8s %8s %8s %8s %8s" % [entry['count'], *sums]

        puts(tally_line + "\n")

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

    end

  end

end

