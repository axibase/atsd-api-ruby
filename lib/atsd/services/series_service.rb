require 'atsd/services/base_service'
require 'atsd/queries/series_query'
require 'atsd/models/series'
require 'atsd/models/entity'
require 'atsd/models/metric'

module ATSD
  class SeriesService < BaseService
    # Create query builder for series.
    #
    # @param [String, Entity] entity
    # @param [String, Metric] metric
    # @param [Hash] options other query parameters
    # @return [SeriesQuery]
    def query(entity, metric, options = {})
      query = SeriesQuery.new @client
      entity = entity.name if entity.is_a? Entity
      metric = metric.name if metric.is_a? Metric
      options.merge! entity: entity, metric: metric
      options.each { |option, value| query[option] = value }
      query
    end

    # Insert time series.
    #
    # @param [Array<Series, Hash>, Series, Hash] series
    # @return [self]
    # @raise [APIError]
    def insert(series)
      series = Utils.ensure_array(series).map do |s|
        s = Series.new(s) if s.is_a? Hash
        s.to_request_hash
      end
      @client.series_insert series
      self
    end

    # Series CSV: Insert
    #
    # @param [String, Entity] entity
    # @param [String] data Payload - CSV containing time column and one or multiple metric columns.
    #   - Separator must be comma.
    #   - Time must be specified in Unix milliseconds.
    #   - Time column must be first, name of the time column could be arbitrary.
    # @param [Hash] tags tag=value hash
    # @return [true]
    # @raise [APIError]
    def csv_insert(entity, data, tags = {})
      entity = entity.name if entity.is_a? Entity
      @client.series_csv_insert(entity, data, tags)
    end
  end
end