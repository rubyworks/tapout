module Koax

  # The TAP adapter transforms traditional TAP format to 
  # modern TAPY format.
  #
  # TODO: implement this adapter!
  class TapAdapter

    def initialize
      @state = [:open]
    end

    def state
      @state
    end

    def <<(line)
      case line
      when /^ok/
        type = :ok
      when /^not\ ok/
        type = :not_ok
      when /^\#/
        type = :comment
      when /^\s+\-\-\-/
        type = :yamlish
      when /^\s+\.\.\./
        type = :end_yamlish
      end
      send("#{type}", line)
    end


    # P A R S E R
 
    #
    def parse_ok(line)
      case state.last
      when :open
        md = /^ok(.*?)((\-?).*?)/.match(line)
        @tobj = {:number=>md[1], :label=>md[2]}
        handle_ok(@tobj)
      when :not_ok
        @state.pop
        handle_not_ok(@tobj)
      end
    end

    def parse_not_ok(line)
      case state.last
      when :open
        md = /^not ok(.*?)((\-?).*?)$/.match(line)
        @state << :not_ok
        @tobj = {:number=>md[1], :label=>md[2]}
      end
    end

    def parse_comment(line)
      case state.last
      when :
        md = /^\#(.*?)$/.match(line)
        @state = :comment
        @comment << md[1]
      end
    end

    def open_yamlish(line)
      raise
    end

    def not_ok_yamlish()
      @state = :yamlish
      @yaml << md[1]
    end

    def comment_comment(line)
      @comment << md[1]
    end

    #def comment_yaml(line)
    #  raise
    #end

    def yamlish_yamlish(line)
      @yaml << line
    end

    def yamlish_end_yamlish(line)
      @yaml << line
      @tobj.merge(YAML.load(@yaml))
      @state = :open
    end


    # H A N D L E R S

    def ok(number, description)
      puts "ok #{number} - #{description}"
    end

    def not_ok(number, description, metainfo)
      puts "not ok #{number} - #{description}"
      puts metadata.to_yaml.sub(/^/, '  ')) if metainfo
    end

  end

end
