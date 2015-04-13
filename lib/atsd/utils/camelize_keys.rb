require 'active_support/core_ext/string/inflections'

module ATSD
  module Utils
    module CamelizeKeys
      def camelize_keys!
        CamelizeKeys.camelize_keys!(self)
        self
      end

      def camelize_keys
        dup.camelize_keys!
      end

      module ClassMethods
        def camelize_keys!(hash)
          hash.keys.each do |k|
            new_key = k.to_s.camelize :lower
            new_key = new_key.to_sym if k.is_a? Symbol
            hash[new_key] = hash.delete(k)
          end
          hash
        end

        def camelize_keys(hash)
          hash.dup.tap do | new_hash |
            camelize_keys! new_hash
          end
        end
      end

      class << self
        include ClassMethods
      end
    end
  end
end

class Hash
  include ATSD::Utils::CamelizeKeys
end