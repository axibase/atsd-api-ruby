require 'atsd/queries/base_query'

module ATSD
  # Class for building and executing Alerts History Query
  # @see https://axibase.com/atsd/api/#alerts:-history-query
  class AlertsHistoryQuery < BaseQuery
    TO_MILLISECONDS_LAMBDA = ->(v) do
      case v
        when Time
          v.to_i * 1_000
        else
          v.to_i
      end
    end

    coerce_key :end_time, TO_MILLISECONDS_LAMBDA
    coerce_key :start_time, TO_MILLISECONDS_LAMBDA

    # @return [Array<AlertHistory>]
    def result
      super
    end

    # @return (see #result)
    def execute
      result = @client.alerts_history_query to_request_hash
      @result = result.map { |json| AlertHistory.new json }
    end
  end
end

