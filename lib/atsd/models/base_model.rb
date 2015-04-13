module ATSD
  # Base class for all models
  # @abstract
  class BaseModel < ::Hash
    include ::Hashie::Extensions::MethodAccess
    include ::Hashie::Extensions::MergeInitializer
    include Utils::UnderscoreKeys

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
  end
end

