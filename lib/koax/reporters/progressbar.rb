require 'koax/reporters/abstract'

require 'ansi/progressbar'

module Koax

  module Reporters

    # The progressbar report format utilises a progress bar to indicate
    # elapsed progress.
    class Progressbar < Abstract

      def start_suite(entry)
        @pbar = ::ANSI::Progressbar.new('Testing', entry['count'].to_i + 1)
        @pbar.style(:bar=>:green)
        @pbar.inc
      end

      def start_case(entry)
      end

      #def test(entry)
      #  #@pbar.inc
      #end

      def pass(entry)
        @pbar.inc
      end

      #
      def fail(entry)
        @pbar.clear

        puts
        message = entry['message'].strip
        message = message.ansi(:red)
        puts(message)
        puts "#{entry['file']}:#{entry['line']}"
        puts
        puts code_snippet(entry)
        puts

        @pbar.style(:bar=>:red)
        @pbar.inc
      end

      #
      def error(message=nil)
        @pbar.clear

        puts
        message = entry['message'].strip
        message = message.ansi(:red)
        puts(message)
        puts "#{entry['file']}:#{entry['line']}"
        puts
        puts code_snippet(entry)
        puts

        @pbar.style(:bar=>:yellow)
        @pbar.inc
      end

      #
      def omit(entry)
        @pbar.inc
      end

      #
      def skip(entry)
        @pbar.inc
      end

      #def finish_case(kase)
      #end

      def finish_suite(entry)
        @pbar.finish
        #post_report(entry)
        puts
        puts tally(entry)
      end

    end

  end

end

