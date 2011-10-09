require 'ansi'
require 'abbrev'

module TapOut

  # Namespace for Report Formats.
  module Reporters

    # Returns a Hash of name to reporter class.
    def self.index
      @index ||= {}
    end

    # Returns a reporter class given it's name or a unique abbreviation of it.
    def self.factory(name)
      list = index.keys.abbrev
      index[list[name]]
    end

    # The Abstract class serves as a base class for all reporters. Reporters
    # must sublcass Abstract in order to be added the the Reporters Index.
    #
    # TODO: Simplify this class and have the sublcasses handle more of the load.
    class Abstract

      # When Abstract is inherited it saves a reference to it in `Reporters.index`.
      def self.inherited(subclass)
        name = subclass.name.split('::').last.downcase
        name = name.chomp('reporter')
        Reporters.index[name] = subclass
      end

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
      def skip(entry)
        @skipped << entry
      end

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
            skip(entry)
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

      # Generate a tally message given a tally or final entry.
      #
      # @return [String] tally message
      def tally_message(entry)
        total = @passed.size + @failed.size + @raised.size #+ @skipped.size + @omitted.size

        if entry['counts']
          total       = entry['counts']['total'] || total
          count_fail  = entry['counts']['fail']  || 0
          count_error = entry['counts']['error'] || 0
        else
          count_fail  = @failed.size
          count_error = @raised.size
        end

        if tally = entry['counts']
          sums = %w{pass fail error todo omit}.map{ |e| tally[e] || 0 }
        else
          sums = [@passed, @failed, @raised, @skipped, @omitted].map{ |e| e.size }
        end

        # ???
        assertions = entry['assertions']
        failures   = entry['failures']

        if assertions
          text = "%s tests: %s pass, %s fail, %s err, %s todo, %omit (%s/%s assertions)"
          text = text % [total, *sums] + [assertions - failures, assertions]
        else
          text = "%s tests: %s pass, %s fail, %s err, %s todo, %s omit"
          text = text % [total, *sums]
        end

        if count_fail > 0
          text.ansi(:red)
        elsif count_error > 0
          text.ansi(:yellow)
        else
          text.ansi(:green)
        end
      end

      # Used to clean-up backtrace.
      #
      # TODO: Use Rubinius global system instead.
      INTERNALS = /(lib|bin)#{Regexp.escape(File::SEPARATOR)}tapout/

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

        len = s.map{ |(n,t)| n }.max.to_s.length

        # ensure proper alignment by zero-padding line numbers
        format = " %5s %0#{len}d %s"

        #s = s.map{|n,t|[n,t]}.sort{|a,b|a[0]<=>b[0]}

        pretty = s.map do |(n,t)|
          format % [('=>' if n == line), n, t.rstrip]
        end #.unshift "[#{region.inspect}] in #{source_file}"

        return pretty
      end

      # Cache source file text. This is only used if the TAP-Y stream
      # doesn not provide a snippet and the test file is locatable.
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

    end#class Abstract

  end#module Reporters

end
