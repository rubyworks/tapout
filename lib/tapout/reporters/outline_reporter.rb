require 'tapout/reporters/abstract'

module Tapout::Reporters

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

      print(' ' * (level_tab - 2))
      puts(case_count(entry) + '. ' + entry['label'].ansi(*config.highlight))
      #puts
    end

    #
    def level_tab
      2 * (@_level + 1)
    end

    #
    def case_count(entry)
      level = entry['level'].to_i
      @_case_count = @_case_count[0,level+1]
      @_case_count[level] ||= 0
      @_case_count[level] += 1
      @_case_count.join('.') #+ '.'
      @_case_count[level].to_s
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
      print(' ' * level_tab)
      puts "#{test_count}. " + entry['label'].ansi(:green) + "   #{entry['source']}"
    end

    def fail(entry)
      super(entry)

      printout(entry, 'FAIL', config.fail)
    end

    def error(entry)
      super(entry)

      printout(entry, 'ERROR', config.error)
    end

    #
    def finish_suite(entry)
      time, rate, avg = time_tally(entry)
      delta = duration(time)

      puts
      print tally_message(entry)
      #puts " [%0.4fs %.4ft/s %.4fs/t] " % [time, rate, avg]
      puts " [%s %.2ft/s %.4fs/t] " % [delta, rate, avg]
    end

  private

    #
    def printout(entry, type, ansi)
      counter = "#{test_count}. "

      label   = entry['label'].ansi(*ansi)
      message = entry['exception']['message']
      exclass = entry['exception']['class']

      parts = [message, exclass].compact.reject{ |x| x.strip.empty? }

      print(' ' * level_tab)
      puts counter + label + "   #{entry['source']}"
      puts
      puts parts.join("\n\n").tabto(level_tab+counter.size)
      puts
      puts backtrace_snippets(entry).tabto(level_tab++counter.size+4)
      print captured_output(entry).tabto(level_tab+counter.size)
      puts
    end

  end

end
