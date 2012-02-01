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

        @index_pad = @suite_size.zero? ? '' : @suite_size.to_s.size

        #@stdout = StringIO.new
        #@stderr = StringIO.new
        #files = suite.collect{ |s| s.file }.join(' ')
        print "Started Suite (#{@suite_size})" ##{suite.name}"
        print " w/ Seed: #{suite['seed']}" if suite['seed']
        puts
      end

      #
      def start_case(kase)
        #if kase.size > 0  # TODO: Don't have size yet?
        #  label = kase['label'].ansi(:bold, :underline)
        #  print "\n#{label}\n\n"
        #end

        @case_stack << kase

        #if last = @case_stack.last
        #  case kase['level'].to_i <=> last['level'].to_i
        #  when 0
        #    @case_stack.pop
        #    @case_stack << kase
        #  when 1
        #    @case_stack << kase
        #  else
        #    while (last = @case_stack.pop)
        #      break if last['level'].to_i < kase['level'].to_i
        #    end
        #    @case_stack << kase
        #  end
        #else
        #  @case_stack << kase
        #end
      end

      #
      def start_test(test)
        @test_time = Time.now
        @test  = test
        @count = @count + 1

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

        code = test['exception']['snippet']
        file = test['exception']['file']
        line = test['exception']['line']

        #if bt = test['exception']['backtrace']
        #  trace = clean_backtrace(bt)
        #else
        #  trace = []
        #  trace << "#{file}:#{line}" if file && line
        #end

        #depth   = config.trace || trace.size
        #trace   = trace[0,depth]

        puts
        if message
          puts
          puts message.tabto(TABSIZE)
        end
        puts

        puts backtrace_snippets(test).tabto(TABSIZE)
        #backtrace_snippets_chain(trace, code, line).each do |(stamp, snip)|
        #  puts stamp.ansi(:bold).tabto(TABSIZE)
        #  if snip
        #    snip = snip.sub(/^(\s*\=\>.*?)$/, '\1'.ansi(:bold))
        #    puts snip.tabto(TABSIZE + 4)
        #  end
        #end

        print captured_output(test).tabto(TABSIZE)
      end

      #
      def error(test)
        stamp_it(test, ERROR, :red)

        #message = exception.to_s.split("\n")[2..-1].join("\n")

        message = test['exception']['message']

        #code = test['exception']['snippet']
        #file = test['exception']['file']
        #line = test['exception']['line']

        #if bt = test['exception']['backtrace']
        #  trace = clean_backtrace(bt)
        #else
        #  trace = []
        #  trace << "#{file}:#{line}" if file && line
        #end

        #depth   = config.trace || trace.size
        #trace   = trace[0,depth]

        puts
        if message && !message.empty?
          puts
          puts message.tabto(TABSIZE)
        end
        puts

        puts backtrace_snippets(test).tabto(TABSIZE)

        #backtrace_snippets_chain(trace, code, line).each do |(stamp, snip)|
        #  puts stamp.ansi(:bold).tabto(TABSIZE)
        #  if snip
        #    snip = snip.sub(/^(\s*\=\>.*?)$/, '\1'.ansi(:bold))
        #    puts snip.tabto(TABSIZE + 4)
        #  end
        #end

        print captured_output(test).tabto(TABSIZE)
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
        @case_stack.pop
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

        kase  = @case_stack.last || {}
        time  = Time.now
        delta = time - @test_time
        #label = test['label']
        label = ("%s %s" % [kase['label'], test['label']]).strip

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

