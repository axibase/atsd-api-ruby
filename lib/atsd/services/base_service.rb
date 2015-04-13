module ATSD
  # Base class for all services
  # @abstract
  class BaseService

    # @param [Client] client ATSD client
    def initialize(client)
      @client = client
    end

    protected

    attr_reader :client
  end
end
