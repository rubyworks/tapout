# MiniTest adaptor for tapout.

require 'minitest/unit'
require 'stringio'

# Becuase of some wierdness in MiniTest
#debug, $DEBUG = $DEBUG, false
#require 'minitest/unit'
#$DEBUG = debug

module MiniTest

  # Runner for MiniTest suites.
  # 
  # This is a heavily refactored version of the built-in MiniTest runner. It's
  # about the same speed, from what I can tell, but is significantly easier to
  # extend.
  # 
  # Based upon Ryan Davis of Seattle.rb's MiniTest (MIT License).
  # 
  # @see https://github.com/seattlerb/minitest MiniTest
  class TapoutRunner < ::MiniTest::Unit

    attr_accessor :suite_start_time, :test_start_time, :reporters
    
    def initialize
      self.report = {}
      self.errors = 0
      self.failures = 0
      self.skips = 0
      self.test_count = 0
      self.assertion_count = 0
      self.verbose = false
      self.reporters = []

      @_source_cache = {}
    end

    # Top level driver, controls all output and filtering.
    def _run args = []
      self.options = process_args args

      self.class.plugins.each do |plugin|
        send plugin
        break unless report.empty?
      end

      return failures + errors if @test_count > 0 # or return nil...
    rescue Interrupt
      abort 'Interrupted'
    end

    #
    def _run_anything(type)
      self.start_time = Time.now
      
      suites = suites_of_type(type)
      tests = suites.inject({}) do |acc, suite|
        acc[suite] = filtered_tests(suite, type)
        acc
      end
      
      self.test_count = tests.inject(0) { |acc, suite| acc + suite[1].length }
      
      if test_count > 0
        trigger(:before_suites, suites, type)
        
        fix_sync do
          suites.each { |suite| _run_suite(suite, tests[suite]) }
        end
        
        trigger(:after_suites, suites, type)
      end
    end
    
    def _run_suite(suite, tests)
      unless tests.empty?
        begin
          self.suite_start_time = Time.now
          
          trigger(:before_suite, suite)
          suite.startup if suite.respond_to?(:startup)
          
          tests.each { |test| _run_test(suite, test) }
        ensure
          suite.shutdown if suite.respond_to?(:shutdown)
          trigger(:after_suite, suite)
        end
      end
    end
    
    #
    def _run_test(suite, test)
      self.test_start_time = Time.now

      trigger(:before_test, suite, test)
      
      test_runner = TestRunner.new(suite, test)
      test_runner.run
      add_test_result(suite, test, test_runner)
      
      trigger(test_runner.result, suite, test, test_runner)
    end
    
    #
    def trigger(callback, *args)
      send("tapout_#{callback}", *args)
    end

    private

    #    
    def filtered_tests(suite, type)
      filter = options[:filter] || '/./'
      filter = Regexp.new($1) if filter =~ /\/(.*)\//
      suite.send("#{type}_methods").grep(filter)
    end
    
    #
    def suites_of_type(type)
      TestCase.send("#{type}_suites")
    end
    
    #
    def add_test_result(suite, test, test_runner)
      self.report[suite] ||= {}
      self.report[suite][test.to_sym] = test_runner
      
      self.assertion_count += test_runner.assertions
      
      case test_runner.result
      when :skip then self.skips += 1
      when :failure then self.failures += 1
      when :error then self.errors += 1
      end
    end

    #
    def fix_sync
      sync = output.respond_to?(:'sync=') # stupid emacs
      old_sync, output.sync = output.sync, true if sync
      yield
      output.sync = old_sync if sync
    end

    #
    def tapout_before_suites(suites, type)
      doc = {
        'type'  => 'suite',
        'start' => self.start_time.strftime('%Y-%m-%d %H:%M:%S'),
        'count' => self.test_count,
        'seed'  => 'fixme'
      }
      puts doc.to_yaml
    end

    #
    def tapout_after_suites(suites, type)
      doc = {
        'type' => 'tally',
        'time' => Time.now - self.test_start_time,
        'counts' => {
          'total' => self.test_count,
          'pass'  => self.test_count - self.failures - self.errors - self.skips,
          'fail'  => self.failures,
          'error' => self.errors,
          'omit'  => self.skips,
          'todo'  => 0  # TODO: does minitest support pending tests?
        }
      }
      puts doc.to_yaml
      puts '...'
    end

    #
    def tapout_before_suite(suite)
      doc = {
        'type'    => 'case',
        'subtype' => '',
        'label'   => "#{suite}",
        'level'   => 0
      }

      puts doc.to_yaml
    end

    #
    def tapout_after_suite(suite)
    end

    #
    def tapout_before_test(suite, test)
    end

    #
    def tapout_pass(suite, test, test_runner)
      doc = {
        'type'        => 'test',
        'subtype'     => '',
        'status'      => 'pass',
        #'setup': foo instance
        'label'       => "#{test}",
        #'expected' => 2
        #'returned' => 2
        #'file' => 'test/test_foo.rb'
        #'line': 45
        #'source': ok 1, 2
        #'snippet':
        #  - 44: ok 0,0
        #  - 45: ok 1,2
        #  - 46: ok 2,4
        #'coverage':
        #  file: lib/foo.rb
        #  line: 11..13
        #  code: Foo#*
        'time' => Time.now - self.suite_start_time
      }
      puts doc.to_yaml
    end

    #
    def tapout_skip(suite, test, test_runner)
      e = test_runner.exeception
      e_file, e_line = location(test_runner.exception)

      doc = {
        'type'        => 'test',
        'subtype'     => '',
        'status'      => 'skip',
        'label'       => "#{suite} #{test}",
        #'setup' => "foo instance",
        #'expected' => 2,
        #'returned' => 1,
        #'file' => test/test_foo.rb
        #'line' => 45
        #'source' => ok 1, 2
        #'snippet' =>
        #  - 44: ok 0,0
        #  - 45: ok 1,2
        #  - 46: ok 2,4
        #'coverage' =>
        #  'file' => lib/foo.rb
        #  'line' => 11..13
        #  'code' => Foo#*
        'exception' => {
          'message'   => clean_message(e.message),
          'file'      => e_file,
          'line'      => e_line,
          #'source'   => '',
          'snippet'   => code_snippet(e_file, e_line),
          'backtrace' => filter_backtrace(e.backtrace)
        },
        'time' => Time.now - self.suite_start_time
      }

      puts doc.to_yaml
    end

    #
    def tapout_failure(suite, test, test_runner)
      e = test_runner.exception
      e_file, e_line = location(test_runner.exception)

      doc = {
        'type'        => 'test',
        'subtype'     => '',
        'status'      => 'fail',
        'label'       => "#{suite} #{test}",
        #'setup' => "foo instance",
        #'expected' => 2,
        #'returned' => 1,
        #'file' => test/test_foo.rb
        #'line' => 45
        #'source' => ok 1, 2
        #'snippet' =>
        #  - 44: ok 0,0
        #  - 45: ok 1,2
        #  - 46: ok 2,4
        #'coverage' =>
        #  'file' => lib/foo.rb
        #  'line' => 11..13
        #  'code' => Foo#*
        'exception' => {
          'message'   => clean_message(e.message),
          'file'      => e_file,
          'line'      => e_line,
          #'source'    => '',
          'snippet'   => code_snippet(e_file, e_line),
          'backtrace' => filter_backtrace(e.backtrace)
        },
        'time' => Time.now - self.suite_start_time
      }

      puts doc.to_yaml
    end

    #
    def tapout_error(suite, test, test_runner)
      e = test_runner.exception
      e_file, e_line = location(test_runner.exception)

      doc = {
        'type'        => 'test',
        'subtype'     => '',
        'status'      => 'error',
        'label'       => "#{suite} #{test}",
        #'setup' => "foo instance",
        #'expected' => 2,
        #'returned' => 1,
        #'file' => test/test_foo.rb
        #'line' => 45
        #'source' => ok 1, 2
        #'snippet' =>
        #  - 44: ok 0,0
        #  - 45: ok 1,2
        #  - 46: ok 2,4
        #'coverage' =>
        #  'file' => lib/foo.rb
        #  'line' => 11..13
        #  'code' => Foo#*
        'exception' => {
          'message'   => clean_message("#{e.class}: #{e.message}"),
          'file'      => e_file,
          'line'      => e_line,
          #'source'    => '',
          'snippet'   => code_snippet(e_file, e_line),
          'backtrace' => filter_backtrace(e.backtrace)
        },
        'time' => Time.now - self.suite_start_time
      }

      puts doc.to_yaml
    end

    #
    INTERNALS = /(lib|bin)#{Regexp.escape(File::SEPARATOR)}tapout/

    #
    def filter_backtrace(bt)
      bt = clean_backtrace(bt)
      bt = MiniTest::filter_backtrace(bt)
      bt
    end

    # Clean the backtrace of any reference to ko/ paths and code.
    def clean_backtrace(backtrace)
      trace = backtrace.reject{ |bt| bt =~ INTERNALS }
      trace = trace.map do |bt| 
        if i = bt.index(':in')
          bt[0...i]
        else
          bt
        end
      end
      trace = backtrace if trace.empty?
      trace = trace.map{ |bt| bt.sub(Dir.pwd+File::SEPARATOR,'') }
      trace
    end

    # Returns a String of source code.
    def code_snippet(file, line)
      s = []

      #case snippet
      #when String
      #  lines = snippet.lines.to_a
      #  index = line - ((lines.size - 1) / 2)
      #  lines.each do |line|
      #    s << [index, line]
      #    index += 1
      #  end
      #when Array
      #  snippet.each do |h|
      #    s << [h.key, h.value]
      #  end
      #else
        ##backtrace = exception.backtrace.reject{ |bt| bt =~ INTERNALS }
        ##backtrace.first =~ /(.+?):(\d+(?=:|\z))/ or return ""
        #caller =~ /(.+?):(\d+(?=:|\z))/ or return ""
        #source_file, source_line = $1, $2.to_i

        if File.file?(file)
          source = source(file)
          radius = 2 # TODO: make customizable (number of surrounding lines to show)
          region = [line - radius, 1].max ..
                   [line + radius, source.length].min

          s = region.map do |n|
            {n => source[n-1].chomp}
          end
        end
      #end
      return s
    end

    # Cache source file text. This is only used if the TAP-Y stream
    # doesn not provide a snippet and the test file is locatable.
    def source(file)
      @_source_cache[file] ||= (
        File.readlines(file)
      )
    end

    # Parse source location from caller, caller[0] or an Exception object.
    def parse_source_location(caller)
      case caller
      when Exception
        trace  = caller.backtrace.reject{ |bt| bt =~ INTERNALS }
        caller = trace.first
      when Array
        caller = caller.first
      end
      caller =~ /(.+?):(\d+(?=:|\z))/ or return ""
      source_file, source_line = $1, $2.to_i
      returnf source_file, source_line
    end

    # Get location of exception.
    def location e # :nodoc:
      last_before_assertion = ""
      e.backtrace.reverse_each do |s|
        break if s =~ /in .(assert|refute|flunk|pass|fail|raise|must|wont)/
        last_before_assertion = s
      end
      file, line = last_before_assertion.sub(/:in .*$/, '').split(':')
      line = line.to_i if line
      return file, line
    end

    #
    def clean_message(message)
      message.strip #.gsub(/\s*\n\s*/, "\n")
    end

  end


  # Runner for individual MiniTest tests.
  # 
  # You *should not* create instances of this class directly. Instances of
  # {SuiteRunner} will create these and send them to the reporters.
  # 
  # Based upon Ryan Davis of Seattle.rb's MiniTest (MIT License).
  # 
  # @see https://github.com/seattlerb/minitest MiniTest
  class TestRunner
    attr_reader :suite, :test, :assertions, :result, :exception
    
    def initialize(suite, test)
      @suite = suite
      @test = test
      @assertions = 0
    end
    
    def run
      suite_instance = suite.new(test)
      @result, @exception = fix_result(suite_instance.run(self))
      @assertions = suite_instance._assertions
    end
    
    def puke(suite, test, exception)
      case exception
      when MiniTest::Skip then [:skip, exception]
      when MiniTest::Assertion then [:failure, exception]
      else [:error, exception]
      end
    end
    
    private
    
    def fix_result(result)
      result == '.' ? [:pass, nil] : result
    end
  end

end


=begin

  # MiniTest runner to produce tapout format test report streams.
  #
  class MiniRunner < ::MiniTest::Unit

    #
    def initialize
      #@turn_config = Turn.config
      super()

      # route minitests traditional output to nowhere
      # (instead of overriding #puts and #print)
      @@out = ::StringIO.new
    end

    # Turn calls this method to start the test run.
    def start(args=[])
      # minitest changed #run in 6023c879cf3d5169953e on April 6th, 2011
      if ::MiniTest::Unit.respond_to?(:runner=)
        ::MiniTest::Unit.runner = self
      end
      # FIXME: why isn't @test_count set?
      run(args)
      #return @turn_suite
    end

    # Override #_run_suite to setup Turn.
    def _run_suites suites, type
      #@turn_suite = Turn::TestSuite.new(@turn_config.suite_name)
      @tap_size = ::MiniTest::Unit::TestCase.test_suites.size
      @tap_tome = Time.now

      puts {
        'type'  => 'suite',
        'start' => @tap_time.strftime('%Y-%m-%d %H:%M:%S')
        'count' => @tap_size
      }.to_yaml

      #if @turn_config.matchcase
      #  suites = suites.select{ |suite| @turn_config.matchcase =~ suite.name }
      #end

      result = suites.map { |suite| _run_suite(suite, type) }

      puts {
        'type' => 'tally',
        'time' => @tap_time - Time.now,
        'counts' => {
          'total' => 2,
          'pass'  => 1,
          'fail'  => 1,
          'error' => 0,
          'omit'  => 0,
          'todo'  => 0
        }
      }.to_yaml

      puts '...'

      return result
    end

    #
    def _run_suite suite, type
      # suites are cases in minitest
      @turn_case = @turn_suite.new_case(suite.name)

      filter = @turn_config.pattern || /./

      suite.send("#{type}_methods").grep(filter).each do |test|
        @turn_case.new_test(test)
      end

      turn_reporter.start_case(@turn_case)

      header = "#{type}_suite_header"
      puts send(header, suite) if respond_to? header

      assertions = @turn_case.tests.map do |test|
        @turn_test = test
        turn_reporter.start_test(@turn_test)

        inst = suite.new(test.name) #method
        inst._assertions = 0

        result = inst.run self

        if result == "."
          turn_reporter.pass
        end

        turn_reporter.finish_test(@turn_test)

        inst._assertions
      end

      @turn_case.count_assertions = assertions.inject(0) { |sum, n| sum + n }

      turn_reporter.finish_case(@turn_case)

      return assertions.size, assertions.inject(0) { |sum, n| sum + n }
    end

    # Override #puke to update Turn's internals and reporter.
    def puke(klass, meth, err)
      case err
      when MiniTest::Skip
        @turn_test.skip!
        turn_reporter.skip #(e)
      when MiniTest::Assertion
        @turn_test.fail!(err)
        turn_reporter.fail(err)
      else
        @turn_test.error!(err)
        turn_reporter.error(err)
      end
      super(klass, meth, err)
    end

    # To maintain compatibility with old versions of MiniTest.
    #
    # Hey, Ryan Davis wrote this code!
    if ::MiniTest::Unit::VERSION < '2.0'    
      #attr_accessor :options

      #
      def run(args=[])
        suites = ::MiniTest::Unit::TestCase.test_suites
        return if suites.empty?

        @test_count, @assertion_count = 0, 0
        sync = @@out.respond_to? :"sync=" # stupid emacs
        old_sync, @@out.sync = @@out.sync, true if sync

        results = _run_suites suites, :test #type

        @test_count      = results.inject(0) { |sum, (tc, _)| sum + tc }
        @assertion_count = results.inject(0) { |sum, (_, ac)| sum + ac }

        @@out.sync = old_sync if sync

        return failures + errors if @test_count > 0 # or return nil...
      rescue Interrupt
        abort 'Interrupted'
      end

    end

  end

end

=end
