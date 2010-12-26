require 'koax/reporters'

require 'yaml'

module Koax

  #
  class TAPYParser

    #
    def initialize(options={})
      format = options[:format] || :dotprogress
      @reporter = Reporters.factory(format).new
    end

    # TODO: write this as a YAML stream parser
    def consume(io)
      doc = ''
      while line = io.gets
        case line
        when /^\-\-\-/
          handle doc
          doc = ''
          doc << line
        else
          doc << line
        end
      end
      handle doc
      stop
    end

    #
    def handle(doc)
      return if doc == ''
      entry = YAML.load(doc)
      @reporter.handle(entry)
    end

    #
    def stop
      #@reporter.handle(entry)
    end

  end

end
