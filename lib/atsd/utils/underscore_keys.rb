require 'active_support/core_ext/string/inflections'

module ATSD
  module Utils
    module UnderscoreKeys
      def self.included(base)
        base.send :include, InstanceMethods

        base.send :alias_method, :set_value_without_underscore, :[]= unless base.method_defined?(:set_value_without_underscore)
        base.send :alias_method, :[]=, :set_value_with_underscore
      end

      module InstanceMethods
        def set_value_with_underscore(key, value)
          key = key.to_s.underscore.to_sym
          set_value_without_underscore(key, value)
        end
      end
    end
  end
end
