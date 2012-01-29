module Tapout

  #
  #
  def self.config
    @config ||= Config.new
  end

  #
  #
  class Config

    def initialize
      initialize_defaults
    end

    def initialize_defaults
      @trace = nil
      @lines = 3

      @minimal = false

      @highlight = [:bold]
      @fadelight = [:dark]

      @pass  = [:green]
      @fail  = [:red]
      @error = [:red]
      @todo  = [:yellow]
      @omit  = [:yellow]
    end

    #
    attr :trace

    #
    def trace=(depth)
      @trace = depth.to_i
    end

    #
    attr :lines

    #
    def lines=(count)
      @lines = count.to_i
    end

    #
    def minimal?
      @minimal
    end
 
    #
    def minimal=(boolean)
      @minimal = boolean ? true : false
    end

    # ANSI highlight 
    attr :highlight

    def highlight=(ansi)
      @highlight = [ansi].flatten
    end

    # ANSI pass
    attr :pass

    def pass=(ansi)
      @pass = [ansi].flatten
    end

    # ANSI fail
    attr :fail

    def fail=(ansi)
      @fail = [ansi].flatten
    end

    # ANSI err
    attr :error

    def error=(ansi)
      @error = [ansi].flatten
    end

    # ANSI todo
    attr :todo

    def todo=(ansi)
      @todo = [ansi].flatten
    end

    # ANSI omit
    attr :omit

    def omit=(ansi)
      @omit = [ansi].flatten
    end

  end

end
