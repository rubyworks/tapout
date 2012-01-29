module Tapout
  # The current revision of the TAP-Y/J format.
  REVISION = "4"

  # Project metadata.
  #
  # @return [Hash] metadata from .ruby file
  def self.metadata
    @metadata ||= (
      require 'yaml'
      YAML.load_file(File.join(File.dirname(__FILE__), '/../tapout.yml'))
    )
  end

  # Any missing constant will be looked for in 
  # project metadata.
  def self.const_missing(name)
    metadata[name.to_s.downcase] || super(name)
  end
end
