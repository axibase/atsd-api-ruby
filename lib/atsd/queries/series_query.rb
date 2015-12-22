require 'atsd/queries/base_query'

module ATSD
  # Class for building and executing Series Query
  # @see https://axibase.com/atsd/api/#series:-query
  class SeriesQuery < BaseQuery

    coerce_key :end_time, TO_MILLISECONDS_LAMBDA
    coerce_key :start_time, TO_MILLISECONDS_LAMBDA

    # @return [Array<Series>]
    def result
      super
    end

    # Add tag to `tags` parameter
    #
    # @param [String] name tag name
    # @param [String, Array<String>] values possible tag value of array of values.
    #   `*` and `?` wildcards allowed.
    # @return [self]
    def tag_add(name, values)
      self[:tags][name] = Utils.ensure_array(values)
      self
    end

    # Executes query and sets `result` attribute.
    #
    # @return (see #result)
    def execute
      result = @client.series_query to_request_hash
      @result = result.map { |series_json| Series.new series_json }
    end

    # Executes multiple queries at the same time. Adds `request_id` parameter
    # to each query if necessary. All queries will have a corresponding `series`
    # attribute set.
    #
    # @param [SeriesQuery] others list of series query to execute with receiver
    # @return [Array<Series>] all results
    def execute_with(*others)
      others ||= []
      queries = [self] + others
      queries_by_id = {}
      if queries.count > 1
        queries.each_with_index do |query, index|
          query.request_id("query_#{index}") unless query.request_id
          query.result = []
          queries_by_id[query[:request_id]] = query
        end
      end

      results = @client.series_query queries.map {|q| q.to_request_hash}
      results.map! { |json| Series.new(json) }
      results.each { |r| queries_by_id[r.request_id].result << r }
    end
  end

  # `type` parameter possible values
  module Type
    HISTORY = 'HISTORY' # default
    FORECAST = 'FORECAST'
    FORECAST_DEVIATION = 'FORECAST_DEVIATION'
  end

  # `join.type` parameter possible values
  module JoinType
    COUNT = 'COUNT'
    MIN = 'MIN'
    MAX = 'MAX'
    AVG = 'AVG'
    SUM = 'SUM'
    PERCENTILE_999 = 'PERCENTILE_999'
    PERCENTILE_995 = 'PERCENTILE_995'
    PERCENTILE_99 = 'PERCENTILE_99'
    PERCENTILE_95 = 'PERCENTILE_95'
    PERCENTILE_90 = 'PERCENTILE_90'
    PERCENTILE_75 = 'PERCENTILE_75'
    PERCENTILE_50 = 'PERCENTILE_50'
    STANDARD_DEVIATION = 'STANDARD_DEVIATION'
  end

  # `join.interpolate` parameter possible values
  module JoinInterpolate
    STEP = 'STEP' # default
    NONE = 'NONE'
    LINEAR = 'LINEAR'
  end

  # `aggregate.type` parameter possible values
  module AggregateType
    DETAIL = 'DETAIL'
    COUNT = 'COUNT'
    MIN = 'MIN'
    MAX = 'MAX'
    AVG = 'AVG'
    SUM = 'SUM'
    PERCENTILE_999 = 'PERCENTILE_999'
    PERCENTILE_995 = 'PERCENTILE_995'
    PERCENTILE_99 = 'PERCENTILE_99'
    PERCENTILE_95 = 'PERCENTILE_95'
    PERCENTILE_90 = 'PERCENTILE_90'
    PERCENTILE_75 = 'PERCENTILE_75'
    PERCENTILE_50 = 'PERCENTILE_50'
    STANDARD_DEVIATION = 'STANDARD_DEVIATION'
    FIRST = 'FIRST'
    LAST = 'LAST'
    DELTA = 'DELTA'
    WAVG = 'WAVG'
    WTAVG = 'WTAVG'
    THRESHOLD_COUNT = 'THRESHOLD_COUNT'
    THRESHOLD_DURATION = 'THRESHOLD_DURATION'
    THRESHOLD_PERCENT = 'THRESHOLD_PERCENT'
  end

  # `aggregate.interpolate` parameter possible values
  module AggregateInterpolate
    STEP = 'STEP'
    NONE = 'NONE'
    LINEAR = 'LINEAR'
  end

  # period's unit possible values
  module Period
    MILLISECOND = 'MILLISECOND'
    SECOND = 'SECOND'
    MINUTE = 'MINUTE'
    HOUR = 'HOUR'
    DAY = 'DAY'
    WEEK = 'WEEK'
    MONTH = 'MONTH'
    QUARTER = 'QUARTER'
    YEAR = 'YEAR'
  end

end

