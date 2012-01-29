require 'tapout/reporters/abstract'

module Tapout

  module Reporters

    # The Breakdown report format gives a tally for each test case.
    #
    class BreakdownReporter < Abstract

      def initialize
        super
        @case = {}
        @case_entries = []
      end

      def start_suite(entry)
        headers = [ 'TESTCASE', 'TESTS', 'PASS', 'FAIL', 'ERROR', 'TODO', 'OMIT' ]
        puts "\n%-20s       %8s %8s %8s %8s %8s %8s\n" % headers
        puts ("-" * 80)
      end

      def start_case(entry)
        @case = entry
        @case_entries = []
      end

      def start_test(entry)
        @case_entries << entry
      end

      #
      def finish_case(entry)
        label  = entry['label'][0,19]
        groups = @case_entries.group_by{ |e| e['status'] }

        total = @case_entries.size
        sums  = %w{pass fail error todo omit}.map{ |n| groups[n] ? groups[n].size : 0 }

        result = sums[1] + sums[2] > 0 ? "FAIL".ansi(:red) : "PASS".ansi(:green)

        puts "%-20s      %8s %8s %8s %8s %8s %8s    [%s]" % ([label, total] + sums + [result])
      end

      #
      def finish_suite(entry)
        post_report(entry)
      end

      #
      def post_report(entry)

        sums = count_tally(entry) #%w{pass fail error todo}.map{ |n| entry['counts'][n] || 0 }

        tally_line = "%-20s      " % "TOTAL"
        tally_line << "%8s %8s %8s %8s %8s %8s" % sums

        puts ("-" * 80)
        puts(tally_line + "\n")

        index = 1

        unless @failed.empty?
          puts
          @failed.each do |test|
            printout(test, index, *config.fail)
            index += 1
          end
          puts
        end

        unless @raised.empty?
          puts
          @raised.each do |test|
            printout(test, index, *config.fail)
            index += 1
          end
          puts
        end

        time, rate, avg = time_tally(entry)

        puts "Finished in %.4fs at %.2f tests/s." % [time, rate, avg]
        puts
        puts tally_message(entry)
      end

    private

      def printout(test, index, *ansi)
        x = test['exception']

        label   = test['label'].to_s
        exclass = test['exception']['class']
        message = test['exception']['message']

        exclass = nil if exclass.to_s.strip.empty?
        message = nil if message.to_s.strip.empty?

        print "#{index}. "
        print label.ansi(*config.highlight)
        print " " + exclass.ansi(*ansi) if exclass
        puts
        puts message.tabto(4) if message
        puts backtrace_snippets(test).tabto(4)
        puts captured_output(test).tabto(4)
        puts
      end

    end

  end

end
