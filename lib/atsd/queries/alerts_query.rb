require 'atsd/queries/base_query'

module ATSD
  # Class for building and executing Alerts Query
  # @see https://axibase.com/atsd/api/#alerts:-query
  class AlertsQuery < BaseQuery
    # `severity` levels
    module Severity
      UNDEFINED = 0
      UNKNOWN = 1
      NORMAL = 2
      WARNING = 3
      MINOR = 4
      MAJOR = 5
      CRITICAL = 6
      FATAL = 7
    end

    # @return [Array<Alert>]
    def result
      super
    end

    # @return (see #result)
    def execute
      result = @client.alerts_query to_request_hash
      @result = result.map { |json| Alert.new json }
    end
  end
end

