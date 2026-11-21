require 'tapout/reporters/abstract'

module Tapout::Reporters

  # Tap Reporter
  class TapReporter < Abstract

    #
    def start_suite(entry)
      @start = Time.now
      @i = 0
      #n = 0
      #suite.concerns.each{ |f| f.concerns.each { |s| n += s.ok.size } }
      @plan = entry['count']
      puts "1..#{@plan}" if @plan
    end

    # Without a count at the start, the plan goes at the end.
    def finish_suite(entry)
      puts "1..#{@i}" unless @plan
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
      body << [x['class'], x['message']].reject{ |s| s.to_s.empty? }.join(': ')
      #body << "#{x['message']}"
      body << ""
      body << code_snippet(entry)
      body << ""
      body = body.join("\n").gsub(/^/, '  # ')

      puts "not ok #{@i} - #{entry['label']}"
      puts body
    end

    # A test still to be done is `not ok` with a TODO directive, which
    # TAP consumers don't count as a failure.
    def todo(entry)
      super(entry)

      @i += 1
      puts "not ok #{@i} - #{entry['label']} # TODO #{directive_reason(entry)}".rstrip
    end

    # An omitted test is `ok` with a SKIP directive.
    def omit(entry)
      super(entry)

      @i += 1
      puts "ok #{@i} - #{entry['label']} # SKIP #{directive_reason(entry)}".rstrip
    end

  private

    # The reason for a directive, on one line.
    def directive_reason(entry)
      reason = entry['reason'] || (entry['exception'] || {})['message']
      reason.to_s.lines.first.to_s.strip
    end
  end

end

