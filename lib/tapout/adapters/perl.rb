require 'tapout/version'

module TapOut

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
    end

    # We need to keep an internal list of all entries
    # in order to create a proper footer.
    attr :entries

    # Convert input stream to TAP-Y string.
    def to_s
      self | ""
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
      when /^\d+\.\.\d+/
        #parse(@cache) if @state != :plan
        return if @head
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
        count = md[2].to_i - md[1].to_i + 1
        entry = {'count'=>count, 'type'=>'suite', 'rev'=>REVISION}
      when :ok
        line = cache[0]
        md = /^ok\s+(\d+)\s*\-?\s*(.*?)($|#)/.match(line)
        entry = {'type'=>'test','status'=>'pass','index'=>md[1].to_i, 'label'=>md[2]}
      when :not_ok
        line = cache[0]
        yaml = cache[1..-2].join('')
        data = YAML.load(yaml)
        md = /^not ok\s+(\d+)\s*\-?\s*(.*?)($|#)/.match(line)
        entry = convert_not_ok(md[1], md[2], data)
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
        entry['exception']['message'] = data['description']

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
      entry['type'] = 'tally'
      entry['counts'] = {
        'total' => @count,
        'pass'  => (groups['pass'] || []).size,
        'fail'  => (groups['fail'] || []).size
      }
      entry
    end

  end

end
