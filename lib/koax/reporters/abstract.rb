require 'ansi'

module KO

  module Reporters

    #
    def self.factory(name)
      Reporters.const_get(name.to_s.capitalize)
    end

    #
    class Abstract

      def initialize
        @passed = []
        @failed = []
        @raised = []
        @source = {}
      end

      #
      def start(tag, *args)
        case tag
        when :suite
          start_suite(*args)
        when :all, :concern
          start_concern(*args)
        when :each, :test, :ok
          start_ok(*args)
        else
          # ???
        end
      end

      #
      def finish(tag, *args)
        case tag
        when :suite
          finish_suite(*args)
        when :all, :concern
          finish_concern(*args)
        when :each, :test, :ok
          finish_ok(*args)
        else
          # ???
        end
      end

      #
      def start_suite(suite)
      end

      #
      def start_concern(concern)
      end

      #
      def start_ok(ok)
      end

      #
      def pass(ok)
        @passed << ok
      end

      #
      def fail(ok, exception)
        @failed << [ok, exception]
      end

      #
      def err(ok, exception)
        @raised << [ok, exception]
      end

      #
      def finish_ok(ok)
      end

      #
      def finish_concern(concern)
      end

      #
      def finish_suite(suite)
      end

      # FIXME: KO needs to track it;s own count b/x it no longer uses AE.
      def tally
        return ""

        text = "%s concerns: %s passed, %s failed, %s errored (%s/%s assertions)"
        total = @passed.size + @failed.size + @raised.size
        text = text % [total, @passed.size, @failed.size, @raised.size, $assertions - $failures, $assertions]
        if @failed.size > 0
          text.ansi(:red)
        elsif @raised.size > 0
          text.ansi(:yellow)
        else
          text.ansi(:green)
        end
      end

      fs = Regexp.escape(File::SEPARATOR)
      INTERNALS = /(lib|bin)#{fs}ko/

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

      # Have to thank Suraj N. Kurapati for the crux of this code.
      def code_snippet(source_file, source_line) #exception
        ##backtrace = exception.backtrace.reject{ |bt| bt =~ INTERNALS }
        ##backtrace.first =~ /(.+?):(\d+(?=:|\z))/ or return ""
        #caller =~ /(.+?):(\d+(?=:|\z))/ or return ""
        #source_file, source_line = $1, $2.to_i

        source = source(source_file)

        radius = 3 # number of surrounding lines to show
        region = [source_line - radius, 1].max ..
                 [source_line + radius, source.length].min

        # ensure proper alignment by zero-padding line numbers
        format = " %2s %0#{region.last.to_s.length}d %s"

        pretty = region.map do |n|
          format % [('=>' if n == source_line), n, source[n-1].chomp]
        end #.unshift "[#{region.inspect}] in #{source_file}"

        pretty
      end

      #
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

