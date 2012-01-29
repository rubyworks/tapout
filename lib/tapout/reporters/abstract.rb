require 'ansi'
require 'abbrev'

module Tapout

  # Namespace for Report Formats.
  module Reporters

    #
    DEAFULT_REPORTER = 'dot'

    # Returns a Hash of name to reporter class.
    def self.index
      @index ||= {}
    end

    # Returns a reporter class given it's name or a unique abbreviation of it.
    # If `name` is `nil` then the default dot reporter is returned.
    def self.factory(name)
      list = index.keys.abbrev
      rptr = index[list[name || DEAFULT_REPORTER]]
      raise ArgumentError, "Unrecognized reporter -- #{name.inspect}" unless rptr
      rptr
    end

    # The Abstract class serves as a base class for all reporters. Reporters
    # must sublcass Abstract in order to be added the the Reporters Index.
    #
    class Abstract

      # When Abstract is inherited it saves a reference to it in `Reporters.index`.
      def self.inherited(subclass)
        name = subclass.name.split('::').last.downcase
        name = name.chomp('reporter')
        Reporters.index[name] = subclass
      end

      #old_sync, @@out.sync = @@out.sync, true if io.respond_to? :sync=

      # New reporter.
      def initialize
        @passed  = []
        @failed  = []
        @raised  = []
        @skipped = []
        @omitted = []

        @case_stack = []
        @source     = {}
        @exit_code  = 0  # assume passing
      end

      # When all is said and done.
      def finalize
        @exit_code
      end

      # Handle header.
      def start_suite(entry)
        @start_time = Time.now
      end

      # At the start of a new test case.
      def start_case(entry)
      end

      # Handle test. This is run before the status handlers.
      def start_test(entry)
      end

      # Handle test with pass status.
      def pass(entry)
        @passed << entry
      end

      # Handle test with fail status.
      def fail(entry)
        @failed << entry
      end

      # Handle test with error status.
      def error(entry)
        @raised << entry
      end

      # Handle test with omit status.
      def omit(entry)
        @omitted << entry
      end

      # Handle test with skip or pending status.
      def todo(entry)
        @skipped << entry
      end

      # Same as todo.
      alias_method :skip, :todo

      # Handle an arbitray note.
      def note(entry)
      end

      # Handle running tally.
      def tally(entry)
      end

      # When a test unit is complete.
      def finish_test(entry)
      end

      # When a test case is complete.
      def finish_case(entry)
      end

      # Handle final entry.
      def finish_suite(entry)
      end

      # -- H A N D L E R --

      #
      def <<(entry)
        handle(entry)
      end

      # Handler method. This dispatches a given entry to the appropriate
      # report methods.
      def handle(entry)
        case entry['type']
        when 'suite'
          start_suite(entry)
        when 'case'
          complete_cases(entry)
          @case_stack << entry
          start_case(entry)
        when 'note'
          note(entry)
        when 'test'
          start_test(entry)
          case entry['status']
          when 'pass'
            pass(entry)
          when 'fail'
            @exit_code = -1
            fail(entry)
          when 'error'
            @exit_code = -1
            error(entry)
          when 'omit'
            omit(entry)
          when 'todo', 'skip', 'pending'
            todo(entry)
          end
          finish_test(entry)
        when 'tally'
          tally(entry)
        when 'final'
          complete_cases
          finish_suite(entry)
        end
      end

      # Get the exit code.
      def exit_code
        @exit_code
      end

      # Calculate the lapsed time, the rate of testing and average time per test.
      #
      # @return [Array<Float>] Lapsed time, rate and average.
      def time_tally(entry)
        total = @passed.size + @failed.size + @raised.size + @skipped.size + @omitted.size
        total = entry['counts']['total'] || total

        time = (entry['time'] || (Time.now - @start_time)).to_f
        rate = total / time
        avg  = time / total

        return time, rate, avg
      end

      # Return the total counts given a tally or final entry.
      #
      # @return [Array<Integer>] The total, fail, error, todo and omit counts.
      def count_tally(entry)
        total = @passed.size + @failed.size + @raised.size + @skipped.size + @omitted.size
        total = entry['counts']['total'] || total

        if counts = entry['counts']
          pass  = counts['pass']  || @passed.size
          fail  = counts['fail']  || @failed.size
          error = counts['error'] || @raised.size
          todo  = counts['todo']  || @skipped.size
          omit  = counts['omit']  || @omitted.size
        else
          pass, fail, error, todo, omit = *[@passed, @failed, @raised, @skipped, @omitted].map{ |e| e.size }
        end

        return total, pass, fail, error, todo, omit
      end

      # Generate a tally message given a tally or final entry.
      #
      # @return [String] tally message
      def tally_message(entry)
        sums = count_tally(entry)

        total, pass, fail, error, todo, omit = *sums

        # TODO: Assertion counts isn't TAP-Y/J spec, is it a good idea to add ?
        if entry['counts'] && entry['counts']['assertions']
          assertions = entry['counts']['assertions']['pass']
          failures   = entry['counts']['assertions']['fail']
        else
          assertions = nil
          failures   = nil
        end

        text = []
        text << "%s pass".ansi(*config.pass)
        text << "%s fail".ansi(*config.fail)
        text << "%s errs".ansi(*config.error)
        text << "%s todo".ansi(*config.todo)
        text << "%s omit".ansi(*config.omit)
        text = "%s tests: " + text.join(", ")

        if assertions
          text << " (%s/%s assertions)"
          text = text % (sums + [assertions - failures, assertions])
        else
          text = text % sums
        end

        text
      end

      # Give a test entry, returns a clean and filtered backtrace.
      #
      def backtrace(test)
        exception = test['exception']

        trace   = exception['backtrace']
        file    = exception['file']
        line    = exception['line']

        if trace
          trace = clean_backtrace(trace)
        else
          trace = []
          trace << "#{file}:#{line}" if file && line
        end

        trace
      end

      # Used to clean-up backtrace.
      #
      # TODO: Use Rubinius global system instead.
      INTERNALS = /(lib|bin)#{Regexp.escape(File::SEPARATOR)}tapout/

      # Clean the backtrace of any "boring" reference.
      def clean_backtrace(backtrace)
        if ENV['debug']
          trace = backtrace
        else
          trace = backtrace.reject{ |bt| bt =~ INTERNALS }
        end
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

      # Get s nicely formatted string of backtrace and source code, ready
      # for output.
      #
      # @return [String] Formatted backtrace with source code.
      def backtrace_snippets(test)
        string = []
        backtrace_snippets_chain(test).each do |(stamp, snip)|
          string << stamp.ansi(*config.highlight)
          if snip
            if snip.index('=>')
              string << snip.sub(/(\=\>.*?)$/, '\1'.ansi(*config.highlight))
            else
              string << snip
            end
          end
        end
        string.join("\n")
      end

      # Returns an associative array of backtraces along with corresponding
      # source code, if available.
      #
      # @return [Array<String,String>]
      #   Array of backtrace line and source code.
      def backtrace_snippets_chain(test)
        code  = test['exception']['snippet']
        line  = test['exception']['line']

        chain = []
        backtrace(test).each do |bt|
          if md = /(.+?):(\d+)/.match(bt)
            chain << [bt, code_snippet('file'=>md[1], 'line'=>md[2].to_i)]
          else
            chain << [bt, nil]
          end
        end
        # use the tap-y/j snippet if the first file was not found
        chain[0][1] = code_snippet('snippet'=>snippet, 'line'=>line) unless chain[0][1]
        chain
      end

      # Parse a bactrace line into file and line number. Returns nil for both
      # if parsing fails.
      #
      # @return [Array<String,Integer>] File and line number.
      def parse_backtrace(bt)
        if md = /(.+?):(\d+)/.match(bt)
          return md[1], md[2].to_i
        else
          return nil, nil
        end
      end

      # Returns a String of source code.
      def code_snippet(entry)
        file    = entry['file']
        line    = entry['line']
        snippet = entry['snippet']

        s = []

        case snippet
        when String
          lines = snippet.lines.to_a
          index = line - ((lines.size - 1) / 2)
          lines.each do |line|
            s << [index, line]
            index += 1
          end
        when Array
          snippet.each do |h|
            s << [h.keys.first, h.values.first]
          end
        else
          ##backtrace = exception.backtrace.reject{ |bt| bt =~ INTERNALS }
          ##backtrace.first =~ /(.+?):(\d+(?=:|\z))/ or return ""
          #caller =~ /(.+?):(\d+(?=:|\z))/ or return ""
          #source_file, source_line = $1, $2.to_i

          if file && File.file?(file)
            source = source(file)

            radius = 3 # number of surrounding lines to show
            region = [line - radius, 1].max ..
                     [line + radius, source.length].min

            #len = region.last.to_s.length

            s = region.map do |n|
              #format % [n, source[n-1].chomp]
              [n, source[n-1].chomp]
            end
          end
        end

        format_snippet_array(s, line)

#        len = s.map{ |(n,t)| n }.max.to_s.length
#
#        # ensure proper alignment by zero-padding line numbers
#        format = " %5s %0#{len}d %s"
#
#        #s = s.map{|n,t|[n,t]}.sort{|a,b|a[0]<=>b[0]}
#
#        pretty = s.map do |(n,t)|
#          format % [('=>' if n == line), n, t.rstrip]
#        end #.unshift "[#{region.inspect}] in #{source_file}"
#
#        return pretty
      end

      #
      def format_snippet_array(array, line)
        s = array

        len = s.map{ |(n,t)| n }.max.to_s.length

        # ensure proper alignment by zero-padding line numbers
        format = " %5s %0#{len}d %s"

        #s = s.map{|n,t|[n,t]}.sort{|a,b|a[0]<=>b[0]}

        pretty = s.map do |(n,t)|
          format % [('=>' if n == line), n, t.rstrip]
        end #.unshift "[#{region.inspect}] in #{source_file}"

        pretty.join("\n")
      end

      # Cache source file text. This is only used if the TAP-Y stream
      # doesn not provide a snippet and the test file is locatable.
      #
      # @return [String] File contents.
      def source(file)
        @source[file] ||= (
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

      #
      def complete_cases(case_entry=nil)
        if case_entry
          while @case_stack.last and @case_stack.last['level'].to_i >= case_entry['level'].to_i
            finish_case(@case_stack.pop)
          end
        else
          while @case_stack.last
            finish_case(@case_stack.pop)
          end
        end
      end

      #
      def captured_stdout(test)
        stdout = test['stdout'].to_s.strip
        return if stdout.empty?
        if block_given?
          yield(stdout)
        else
          stdout
        end
      end

      #
      def captured_stderr(test)
        stderr = test['stderr'].to_s.strip
        return if stderr.empty?
        if block_given?
          yield(stderr)
        else
          stderr
        end
      end

      #
      def captured_output(test)
        str = ""
        str += captured_stdout(test){ |c| "\nSTDOUT\n#{c.tabto(4)}\n" }.to_s
        str += captured_stderr(test){ |c| "\nSTDERR\n#{c.tabto(4)}\n" }.to_s
        str
      end

      #
      def captured_output?(test)
        captured_stdout?(test) || captured_stderr?(test)
      end

      #
      def captured_stdout?(test)
        stderr = test['stdout'].to_s.strip
        !stderr.empty?
      end

      #
      def captured_stderr?(test)
        stderr = test['stderr'].to_s.strip
        !stderr.empty?
      end

      #
      def duration(seconds, precision=2)
        p = precision.to_i
        s = seconds.to_i
        f = seconds - s
        h, s = s.divmod(60)
        m, s = s.divmod(60)
        "%02x:%02x:%02x.%0#{p}x" % [h, m, s, f * 10**p]
      end

      # Access to configurtion.
      def config
        Tapout.config
      end

    end#class Abstract

  end#module Reporters

end
