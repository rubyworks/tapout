module Tapout

  ##
  #
  class Utility

    def initialize(output=STDOUT)
      @output = output
    end

    def pause
      @output.puts 16.chr

      if block_given?
        block.call
        resume
      end
    end

    def resume
      @output.puts 23.chr
    end

  end

end

# Singleton instance of Tapout::Utility.
#
#   tapout.pause { binding.pry }
#
# Returns Tapout::Utility.
def tapout(output=STDOUT)
  $tapout ||= Tapout::Utility.new(output)
end

