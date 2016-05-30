module ATSD
  # Base class for all models
  # @abstract
  class BaseModel < ::Hash
    include ::Hashie::Extensions::MethodAccess
    include ::Hashie::Extensions::MergeInitializer
    include Utils::UnderscoreKeys
    include ::Hashie::Extensions::Coercion


    # Converts model to hash usable for API
    #
    # @return [Hash]
    def to_request_hash
      hash = {}
      keys.each do |k|
        new_key = k.to_s.camelize(:lower)
        new_key = new_key.to_sym if k.is_a? Symbol
        hash[new_key] = self[k]
      end
      hash
    end

    # Converts time and value keys as t and v respectively
    # for the rest operates as a superclass method
    def []=(key,value)
      if key.to_s == 'date'
        key = :d
        case value
          when Time
            value = value.iso8601
          else
            value = value
        end
      end
      key = :v if key.to_s == 'value'
      super(key, value)
    end

  end
end

