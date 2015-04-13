require 'atsd/utils/camelize_keys'
require 'atsd/utils/underscore_keys'

module ATSD
  module Utils
    # Ensures that object is an array
    # @param [Object] object
    # @return [Array]
    def self.ensure_array(object)
      if object.nil?
        []
      elsif object.respond_to?(:to_ary)
        object.to_ary || [object]
      else
        [object]
      end
    end
  end
end

