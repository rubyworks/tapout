require 'tapout/reporters'

module Tapout

  class AbstractParser

    # ASCII DLE (Data Link Escape)
    PAUSE_DOCUMENT  = 16.chr + "\n" #"...\n"

    # ASCII ETB (End of Transmission Block)
    RESUME_DOCUMENT = 23.chr + "\n" #"---\n"

    # Passthru incoming data directly to `$stdout`.
    #
    def passthru(doc=nil)
      $stdout << doc if doc
      while line = @input.gets
        return line if line == RESUME_DOCUMENT
        $stdout << line
      end
      return ''
    end

  end

end

