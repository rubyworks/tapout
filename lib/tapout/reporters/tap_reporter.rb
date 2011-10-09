require 'tapout/reporters/abstract'

module TapOut::Reporters

  # Tap Reporter
  class TapReporter < Abstract

    #
    def start_suite(entry)
      @start = Time.now
      @i = 0
      #n = 0
      #suite.concerns.each{ |f| f.concerns.each { |s| n += s.ok.size } }
      puts "1..#{entry['count']}"
    end

    #
    def start_case(entry)
      #$stdout.puts concern.label.ansi(:bold)
    end

    #
    #def start_ok(ok)
    #  @i += 1
    #end

    #
    def pass(entry)
      super(entry)

      @i += 1
      #desc = entry['message'] #+ " #{ok.arguments.inspect}"

      puts "ok #{@i} - #{entry['label']}"
    end

    #
    def fail(entry)
      super(entry)

      @i += 1
      x = entry['exception']

      #desc = #ok.concern.label + " #{ok.arguments.inspect}"

      body = []
      body << "FAIL #{x['file']}:#{x['line']}" #clean_backtrace(exception.backtrace)[0]
      body << "#{x['message']}"
      body << code_snippet(entry)
      body = body.join("\n").gsub(/^/, '  # ')

      puts "not ok #{@i} - #{entry['label']}"
      puts body
    end

    #
    def error(entry)
      super(entry)

      @i += 1
      x = entry['exception']

      #desc = ok.concern.label + " #{ok.arguments.inspect}"

      body = []
      body << "ERROR #{x['file']}:#{x['line']}" #clean_backtrace(exception.backtrace)[0..2].join("    \n")
      #body << "#{exception.class}: #{entry['message']}"
      body << "#{x['message']}"
      body << ""
      body << code_snippet(entry)
      body << ""
      body = body.join("\n").gsub(/^/, '  # ')

      puts "not ok #{@i} - #{entry['label']}"
      puts body
    end

    #
    #def pending(ok, exception)
    #  puts "not ok #{@i} - #{unit.description}"
    #  puts "  PENDING"
    #  puts "  #{exception.backtrace[1]}"
    #end
  end

end

