require 'tapout/version'
require 'yaml'

module Tapout

  # The TAP Legacy Adapter transforms traditional TAP format to 
  # modern TAP-Y format.
  #
  # IMPORTANT: This is still very much a work in progress.

  class PerlAdapter

    #
    def initialize(input)
      @input = input
      reset
    end

    # Reset state.
    def reset
      @head    = false
      @state   = nil
      @entries = []
      @cache   = []
      @count   = nil
    end

    # We need to keep an internal list of all entries
    # in order to create a proper footer.
    attr :entries

    # Convert input stream to TAP-Y string.
    def to_s
      self | String.new
    end

    # Route stream to an array of entires.
    def to_a
      self | []
    end

    # Convert input stream to TAP-Y and *pipe* to +output+ stream.
    def |(output)
      @out = output
      reset
      while line = @input.gets
        self << line
      end
      self << nil
      return @out
    end

    #
    def <<(line)
      case line
      when nil
        parse(@cache)
        @state = :footer
        finish
      when /^TAP version/i
        return
      when /^\d+\.\.\d+/
        return if @head
        parse(@cache)
        @head  = true
        @state = :plan
        @cache << line
      when /^ok/
        parse(@cache) #if @state != :ok
        @state = :ok
        @cache << line
      when /^not\ ok/
        parse(@cache) #if @state != :not_ok
        @state = :not_ok
        @cache << line
      when /^\#/
        parse(@cache) if @state != :comment
        @state = :comment
        @cache << line
      else
        @cache << line
      end
    end

    #
    def parse(cache)
      case @state
      when nil
        return
      when :plan
        line = cache[0]
        md = /^(\d+)\.\.(\d+)\s*$/.match(line)
        md = /^(\d+)\.\.(\d+)/.match(line)
        @count = md[2].to_i - md[1].to_i + 1
        entry = {'count'=>@count, 'type'=>'suite', 'rev'=>REVISION}
      when :ok
        number, label, directive, reason = parse_test_line(cache[0])
        entry = {'type'=>'test', 'status'=>'pass', 'index'=>number, 'label'=>label}
        apply_directive(entry, directive, reason)
      when :not_ok
        number, label, directive, reason = parse_test_line(cache[0])
        entry = convert_not_ok(number, label, diagnostics(cache[1..-1]))
        apply_directive(entry, directive, reason)
      when :comment
        desc = cache.map{ |c| c.sub(/^\#\s{0,1}/, '') }.join("\n")
        entry = {'type'=>'note', 'text'=>desc.rstrip}
      end
      output(entry)
      @cache = []
    end

    #
    def output(entry)
      @entries << entry
      case @out
      when String, IO
        @out << entry.to_yaml
      else
        @out << entry
      end
    end

    #
    def finish
      output(make_footer)
      case @out
      when String, IO
        @out << '...'
      end
    end

    private

    # Split a test line into its number, description, and the directive
    # (`skip` or `todo`) and reason that may follow a `#`. The number is
    # optional in TAP; a test without one is numbered in order.
    def parse_test_line(line)
      md = /^(?:not )?ok\b\s*(\d+)?\s*-?\s*(.*)$/.match(line.chomp)
      number = md[1] ? md[1].to_i : @entries.count{ |e| e['type'] == 'test' } + 1
      label, directive, reason = md[2], nil, nil
      if dm = /(\A|\s)#\s*(skip\w*|todo)\b\s*(.*)\z/i.match(label)
        label     = dm.pre_match
        directive = dm[2].downcase.start_with?('skip') ? 'skip' : 'todo'
        reason    = dm[3]
      end
      return number, label.strip, directive, reason
    end

    # In TAP a skipped test is reported `ok`, and one still to be done
    # either way. TAP-Y calls these `omit` and `todo`.
    def apply_directive(entry, directive, reason)
      return unless directive
      entry['status'] = (directive == 'skip' ? 'omit' : 'todo')
      entry['exception'] ||= {}
      entry['exception']['message'] = reason unless reason.to_s.empty?
    end

    # The YAML block that may follow a test line, as a Hash, or nil.
    def diagnostics(lines)
      lines = lines.reject{ |l| l =~ /^\s*(---|\.\.\.)\s*$/ }
      data  = YAML.load(unindent(lines.join('')))
      Hash === data ? data : nil
    rescue Psych::SyntaxError
      nil
    end

    #
    # TODO: Any way to distinguish fail vs error?
    def convert_not_ok(number, label, data)
      entry = {}
      entry['type']   = 'test'
      entry['status'] = 'fail'
      entry['index']  = number.to_i
      entry['label']  = label
      if data
        entry['exception'] = {}
        entry['exception']['file']    = data['file']
        entry['exception']['line']    = data['line']
        entry['exception']['message'] = data['description'] || data['message']

        entry['expected'] = data['wanted']
        entry['returned'] = data['found']
        entry['source']   = data['raw_test']
        entry['extra']    = data['extensions']
      end
      entry
    end

    #
    def make_footer
      groups = @entries.group_by{ |e| e['status'] }

      entry = {}
      entry['type'] = 'final'
      tests = @entries.count{ |e| e['type'] == 'test' }
      entry['counts'] = {
        'total' => @count || tests,
        'pass'  => (groups['pass']  || []).size,
        'fail'  => (groups['fail']  || []).size,
        'error' => (groups['error'] || []).size,
        'omit'  => (groups['omit']  || []).size,
        'todo'  => (groups['todo']  || []).size
      }
      entry
    end

    #
    def unindent(yaml)
      if md = /^\s+/.match(yaml)
        re = Regexp.escape(md[0])
        yaml.gsub(/^#{re}/, '')
      else
        yaml
      end
    end

  end

end
