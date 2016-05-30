require 'atsd/queries/base_query'

module ATSD
  # Class for building and executing Alerts History Query
  # @see https://axibase.com/atsd/api/#alerts:-history-query
  class AlertsHistoryQuery < BaseQuery
    TO_ISO_LAMBDA = ->(v) do
      case v
        when Time
          v.iso8601
        else
          v
      end
    end

    coerce_key :end_date, TO_ISO_LAMBDA
    coerce_key :start_date, TO_ISO_LAMBDA

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

