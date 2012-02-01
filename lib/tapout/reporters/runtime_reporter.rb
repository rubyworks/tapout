require 'tapout/core_ext'
require 'tapout/reporters/abstract'

module Tapout

  module Reporters

    #
    #
    class RuntimeReporter < Abstract

      #
      PADDING_SIZE = 4

      #
      TABSIZE = 4

      # TODO: Fix ANSI for this
      WIDTH = `tput cols`.to_i - 1 #::ANSI::Terminal.terminal_width || ENV['COLUMNS'].to_i

      PASS  = " PASS  "
      SKIP  = " TODO  "
      OMIT  = " SKIP  "
      FAIL  = " FAIL  "
      ERROR = " ERROR "

      #
      def start_suite(suite)
        super(suite)

        @suite  = suite
        @count  = 0
        @index  = 0

        @suite_size = suite['count'].to_i
        @case_stack = []

        # pad for index based on how big the index number will get
        @index_pad = @suite_size.zero? ? '' : @suite_size.to_s.size

        #files = suite['files'].collect{ |s| s.file }.join(' ')

        print "Started Suite (#{@suite_size})" ##{suite.name}"
        print " w/ Seed: #{suite['seed']}" if suite['seed']
        puts
      end

      #
      def start_case(kase)
        #return if kase.size == 0  # TODO: Don't have size yet?
        last = @case_stack.pop
        while last
          break if last['level'].to_i <= kase['level'].to_i
          last = @case_stack.pop
        end

        @case_stack << kase
      end

      #
      def start_test(test)
        @test_time = Time.now
        @test  = test
        @count = @count + 1
      end

      # TODO: Only show if in verbose mode.
      def pass(test)
        stamp_it(test, PASS, :green) unless config.minimal?

        #if message
        #  message = test['source'].ansi(:magenta)
        #  message = message.to_s.tabto(10)
        #  puts(message)
        #end

        # TODO: Is there any reason to show captured output for passing test?
        #if captured_output?(test)
        #  puts captured_output(test).tabto(TABSIZE)
        #end
      end

      #
      def skip(test)
        stamp_it(test, SKIP, :cyan) #unless config.minimal?
      end

      #
      def omit(test)
        stamp_it(test, OMIT, :blue) unless config.minimal?
      end

      #
      def fail(test)
        stamp_it(test, FAIL, :red)

        #message = assertion.location[0] + "\n" + assertion.message #.gsub("\n","\n")
        #trace   = MiniTest::filter_backtrace(report[:exception].backtrace).first

        message = test['exception']['message']

        puts
        if message
          puts
          puts message.tabto(TABSIZE)
        end
        puts

        puts backtrace_snippets(test).tabto(TABSIZE)

        print captured_output(test).tabto(TABSIZE)
      end

      #
      def error(test)
        stamp_it(test, ERROR, :red)

        message = test['exception']['message']

        puts
        if message && !message.empty?
          puts
          puts message.tabto(TABSIZE)
        end
        puts

        puts backtrace_snippets(test).tabto(TABSIZE)

        print captured_output(test).tabto(TABSIZE)
      end

      #
      def finish_test(test)
        puts unless config.minimal?
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

        time, rate, avg = time_tally(final)

        puts
        puts "Finished in %.6f seconds. %.3f tests per second." % [time, rate]
        puts

        print ("%d tests: "  % total)
        #print "%d assertions, " % suite.count_assertions
        print ("%d failures" % fail).ansi(*config.fail) + ', '
        print ("%d errors"   % error).ansi(*config.error) + ', '
        print ("%d pending"  % todo).ansi(*config.todo) + ', '
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

      NOMINAL = []

      #
      def stamp_it(test, type, *color)
        @index += 1

        cases  = @case_stack.map{ |k| k['label'] }.join(' ')
        time  = Time.now
        delta = time - @test_time
        #label = test['label']
        label = [cases, test['label']].join(' ').strip

        indexS = @index
        prcntS = " %3s%% " % [@count * 100 / @suite_size]
        ratioS = " #{@count}/#{@suite_size} "
        deltaS = " %.6f " % [time - @test_time]
         timeS = " " + duration(time - @start_time) #time.strftime(' %H:%M:%S.%L ')
         typeS = type.to_s

        width = WIDTH - (ratioS.size + prcntS.size + deltaS.size + timeS.size + indexS.size + typeS.size + 9)

         typeS = typeS.ansi(*color)

        prcntS = prcntS.ansi(*NOMINAL)
        ratioS = ratioS.ansi(*NOMINAL)

        if delta > 30
          delteS = deltaS.ansi(:yellow)
        elsif delta > 60
          deltaS = deltaS.ansi(:red)
        else
          deltaS = deltaS.ansi(*NOMINAL)
        end

        timeS = timeS.ansi(*NOMINAL)

        stuff = [indexS, typeS, label.ansi(:bold), ratioS, prcntS, deltaS, timeS]

        print " %#{@index_pad}d |%s| %-#{width}s %s|%s|%s|%s" % stuff
      end

    end

  end

end

