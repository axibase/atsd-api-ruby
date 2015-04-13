module ATSD
  # Base class for API query builders
  # @abstract
  class BaseQuery < ::Hashie::Clash
    include ::Hashie::Extensions::Coercion

    # @return [Client]
    attr_reader :client

    # @param [Client] client
    def initialize(client)
      @client = client
    end

    # Build request parameters hash
    # @return [Hash]
    def to_request_hash
      Utils::CamelizeKeys.camelize_keys(self)
    end

    # Execute query on client
    # @return (see #result)
    # @raise [APIError]
    def execute
      raise NotImplementedError
    end

    # Result of query execution.
    #
    # @return [Object]
    # @raise [APIError]
    def result
      @result ||= execute
    end

    protected

    attr_writer :result
  end
end
