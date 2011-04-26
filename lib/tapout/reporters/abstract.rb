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
        Reporters.index[name] = subclass
      end

      # New reporter.
      def initialize
        @passed  = []
        @failed  = []
        @raised  = []
        @skipped = []
        @omitted = []

        @source  = {}
        @previous_case = nil
      end

      #
      def <<(entry)
        handle(entry)
      end

      # Handler method. This dispatches a given entry to the appropriate
      # report methods.
      def handle(entry)
        case entry['type']
        when 'header'
          start_suite(entry)
        when 'case'
          finish_case(@previous_case) if @previous_case
          @previous_case = entry
          start_case(entry)
        when 'note'
          note(entry)
        when 'test'
          test(entry)
          case entry['status']
          when 'pass'
            pass(entry)
          when 'fail'
            fail(entry)
          when 'error'
            err(entry)
          when 'omit'
            omit(entry)
          when 'pending', 'skip'
            skip(entry)
          end
        when 'footer'
          finish_case(@previous_case) if @previous_case
          finish_suite(entry)
        end
      end

      # Handle header.
      def start_suite(entry)
      end

      # At the start of a new test case.
      def start_case(entry)
      end

      # Handle an arbitray note.
      def note(entry)
      end

      # Handle test. This is run before the status handlers.
      def test(entry)
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
      def err(entry)
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

      # When a test case is complete.
      def finish_case(entry)
      end

      # Handle footer.
      def finish_suite(entry)
      end

      # TODO: get the tally's from the footer entry ?
      def tally(entry)
        total = entry['count'] || (@passed.size + @failed.size + @raised.size)

        if entry['tally']
          count_fail  = entry['tally']['fail']  || 0
          count_error = entry['tally']['error'] || 0
        else
          count_fail  = @failed.size
          count_error = @raised.size
        end

        if tally = entry['tally']
          sums = %w{pass fail error skip}.map{ |e| tally[e] || 0 }
        else
          sums = [@passed, @failed, @raised, @skipped].map{ |e| e.size }
        end

        assertions = entry['assertions']
        failures   = entry['failures']

        if assertions
          text = "%s tests: %s pass, %s fail, %s err, %s pending (%s/%s assertions)"
          text = text % [total, *sums] + [assertions - failures, assertions]
        else
          text = "%s tests: %s pass, %s fail, %s err, %s pending"
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

      #
      INTERNALS = /(lib|bin)#{Regexp.escape(File::SEPARATOR)}ko/

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

        if snippet
          len = snippet.map{ |n, t| n }.max.to_s.length

          # ensure proper alignment by zero-padding line numbers
          format = " %5s %0#{len}d %s"

          snippet = snippet.map{|n,t|[n,t]}.sort{|a,b|a[0]<=>b[0]}

          pretty = snippet.map do |(n,t)|
            format % [('=>' if n == line), n, t.rstrip]
          end
        else
          ##backtrace = exception.backtrace.reject{ |bt| bt =~ INTERNALS }
          ##backtrace.first =~ /(.+?):(\d+(?=:|\z))/ or return ""
          #caller =~ /(.+?):(\d+(?=:|\z))/ or return ""
          #source_file, source_line = $1, $2.to_i

          if File.file?(file)
            source = source(file)

            radius = 3 # number of surrounding lines to show
            region = [source_line - radius, 1].max ..
                     [source_line + radius, source.length].min

            len = region.last.to_s.length

            # ensure proper alignment by zero-padding line numbers
            format = " %5s %0#{len}d %s"

            pretty = region.map do |n|
              SOURECE_FORMAT % [('=>' if n == line), n, source[n-1].chomp]
            end #.unshift "[#{region.inspect}] in #{source_file}"
          else
            pretty = ''
          end
        end

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

    end#class Abstract

  end#module Reporters

end
