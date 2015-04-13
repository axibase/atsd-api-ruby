require 'faraday'
require 'faraday_middleware'
require 'hashie'

require 'atsd/version'
require 'atsd/utils'
require 'atsd/atsd'

module ATSD
  # Alias for {ATSD#initialize ATSD::ATSD.new}
  # @param [Hash] options
  #   the configuration options
  # @return [ATSD]
  def self.new(options = {}, &block)
    ATSD.new(options, &block)
  end
end


