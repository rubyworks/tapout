require 'tapout/reporters/abstract'

module TapOut::Reporters

  # Markdown reporter.
  #
  class Markdown < Abstract

    #
    def start_suite(entry)
      @start_time = Time.now
    end

    #
    def mark
      ('#' * (@_level + 1)) + ' '
    end

    #
    def start_case(entry)
      @_level = entry['level'].to_i + 1
      $stdout.print('#' * @_level + ' ')
      $stdout.puts(entry['label'])
    end

    #
    def pass(entry)
      super(entry)
      $stdout.puts "#{mark}" + entry['label'] + "   #{entry['source']}"
    end

    #
    def fail(entry)
      super(entry)

      $stdout.puts "#{mark}" + entry['label'] + "   #{entry['source']}"

      $stdout.puts "\n**MESSAGE**\n\n"
      $stdout.puts entry['exception']['message'].tabto(4)

      $stdout.puts "\n**TYPE**\n\n"
      $stdout.puts entry['exception']['class'].tabto(4)

      #$stdout.puts "    " + ok.caller #clean_backtrace(exception.backtrace)[0]

      $stdout.puts "\n**SNIPPET**\n\n"
      $stdout.puts code_snippet(entry['exception'])

      if captured_stdout?(entry)
        $stdout.puts "\n**STDOUT**\n\n"
        $stdout.puts captured_stdout(entry).tabto(4)
      end

      if captured_stderr?(entry)
        $stdout.puts "\n**STDERR**\n\n"
        $stdout.puts captured_stderr(entry).tabto(4)
      end

      $stdout.puts
    end

    #
    def error(entry)
      super(entry)

      $stdout.puts "#{mark}" + entry['label'] + "   #{entry['source']}"

      $stdout.puts "\n**MESSAGE**\n\n"
      $stdout.puts entry['exception']['message'].tabto(4)

      $stdout.puts "\n**TYPE**\n\n"
      $stdout.puts entry['exception']['class'].tabto(4)

      #$stdout.puts "    " + ok.caller #clean_backtrace(exception.backtrace)[0..2].join("    \n")

      $stdout.puts "\n**SNIPPET**\n\n"
      $stdout.puts code_snippet(entry['exception'])

      if captured_stdout?(entry)
        $stdout.puts "\n**STDOUT**\n\n"
        $stdout.puts captured_stdout(entry).tabto(4)
      end

      if captured_stderr?(entry)
        $stdout.puts "\n**STDERR**\n\n"
        $stdout.puts captured_stderr(entry).tabto(4)
      end

      $stdout.puts
    end

    #
    def finish_suite(entry)
      #$stderr.puts
      $stderr.print tally_message(entry)
      $stderr.puts " [%0.4fs] " % [Time.now - @start_time]
    end

  end

end
