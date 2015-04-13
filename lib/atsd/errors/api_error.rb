require 'atsd/errors/error'

module ATSD
  class APIError < Error
    attr_reader :status

    def initialize(env)
      @status = env.status
    end
  end
end
