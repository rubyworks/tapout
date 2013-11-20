module Tapout

  ##
  # Provides some convenience methods for programs using tapout for testing.
  # Be sure to require this script to use it, e.g. in `test_helper.rb`
  #
  #     require 'tapout/utility'
  #
  class Utility

    # Initialize new Utility instance.
    #
    # input - An input I/O, defaults to STDOUT>
    #
    def initialize(output=STDOUT)
      @output = output
    end

    # Pause tapout processing. This method sends a `16.chr` signal
    # to the output.
    #
    # If a block is given, the block will be called after the pause.
    # Then the block finishes, processing with be automatically resumed.
    #
    #     taoput.pause do
    #       binding.pry
    #     end
    #
    def pause
      @output.puts 16.chr
      if block_given?
        yield
        resume
      end
    end

    # Resume tapout processing. This method sends a `23.chr` signal
    # to the output.
    def resume
      @output.puts 23.chr
    end

    # When using binding.pry while testing with tapout, it is best
    # to tell tapout to pause processing first. This method provides
    # a shortcut for doing exactly with pry.
    #
    # Instead of:
    #
    #     binding.pry
    #
    # use
    #
    #   tapout.pry(binding)
    #
    def pry(binding)
      pause
      binding.pry
      resume
    end

  end

end

# Instance of Tapout::Utility.
#
#     tapout.pause { binding.pry }
#
# Returns Tapout::Utility.
def tapout(output=STDOUT)
  $tapout ||= {}
  $tapout[output] ||= Tapout::Utility.new(output)
end

