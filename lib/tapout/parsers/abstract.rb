require 'tapout/reporters'

module Tapout

  class AbstractParser

    # These codes make a lot of sense for YAML, but not
    # so much for JSON, maybe they should be something
    # esoteric, like an Esc code?

    EXIT_CODE = "...\n"

    RETURN_CODE = "---\n"

    #
    def passthru(doc=nil)
      $stdout << doc if doc
      while line = @input.gets
        return line if line == RETURN_CODE
        $stdout << line
      end
      return ''
    end

  end

end

