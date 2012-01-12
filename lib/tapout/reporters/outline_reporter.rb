require 'tapout/reporters/abstract'

module TapOut::Reporters

  # Outline reporter.
  #
  # TODO: Not sure there is really any good point to this reporter.
  #
  class Outline < Abstract

    #
    def start_suite(entry)
      @_case_count = [0]
      @start_time = Time.now
    end

    #
    def start_case(entry)
      @_test_count = 0
      @_level = entry['level'].to_i

      $stdout.print(' ' * (level_tab - 2))
      $stdout.puts(case_count(entry) + ' ' + entry['label'].ansi(:bold))
    end

    #
    def level_tab
      2 * (@_level + 1)
    end

    #
    def case_count(entry)
      level = entry['level'].to_i
      @_case_count = @_case_count[0,level]
      @_case_count[level] ||= 0
      @_case_count[level] += 1
      @_case_count.join('.') + '.'
    end

    #
    def start_test(test)
      @_test_count += 1
    end

    #
    def test_count
      @_test_count
    end

    #
    def pass(entry)
      super(entry)
      $stdout.print(' ' * level_tab)
      $stdout.puts "#{test_count}. " + entry['label'].ansi(:green) + "   #{entry['source']}"
    end

    def fail(entry)
      super(entry)

      msg = entry['exception'].values_at('message', 'class').compact.join("\n\n")

      $stdout.print(' ' * level_tab)
      $stdout.puts "#{test_count}. " + entry['label'].ansi(:red) + "   #{entry['source']}"
      $stdout.puts
      $stdout.puts msg.tabto(level_tab+6)
      #$stdout.puts "    " + ok.caller #clean_backtrace(exception.backtrace)[0]
      $stdout.puts
      $stdout.puts code_snippet(entry['exception']).join("\n").tabto(level_tab+9)
      $stdout.print captured_output(entry).tabto(level_tab+6)
      $stdout.puts
    end

    def error(entry)
      super(entry)

      msg = entry['exception'].values_at('message', 'class').compact.join("\n\n")

      $stdout.print(' ' * level_tab)
      $stdout.puts "#{test_count}. " + entry['label'].ansi(:yellow) + "   #{entry['source']}"
      $stdout.puts
      $stdout.puts msg.tabto(level_tab+6)
      #$stdout.puts "    " + ok.caller #clean_backtrace(exception.backtrace)[0..2].join("    \n")
      $stdout.puts
      $stdout.puts code_snippet(entry['exception']).join("\n").tabto(level_tab+9)
      $stdout.print captured_output(entry).tabto(level_tab+6)
      $stdout.puts
    end

    #
    def finish_suite(entry)
      #$stderr.puts
      $stdout.print tally_message(entry)
      $stdout.puts " [%0.4fs] " % [Time.now - @start_time]
    end

  end

end
