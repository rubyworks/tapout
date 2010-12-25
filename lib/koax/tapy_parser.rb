require 'yaml'

module Koax

  #
  class TAPYParser

    def initialize(io)
      @io = io
    end

    def parse
      doc = ''
      case line = io.gets
      when /^---/
        handle doc
        doc = ''
      when /^.../
        stop
      end
    end


  end

end
