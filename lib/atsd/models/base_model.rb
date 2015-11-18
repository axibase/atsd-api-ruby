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

    # def method_missing(meth, *args, &block)
    #   action = meth[0, 3]
    #   field = meth[4..-1]
    #   case action
    #     when "get"
    #       return self.send(field)
    #     when "set"
    #       return self[field]=args[0]
    #     else
    #       super
    #   end
    # end
  end
end

