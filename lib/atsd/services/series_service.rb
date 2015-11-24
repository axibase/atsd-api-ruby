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
    # @param [Fixnum] start_time
    # @param [Fixnum] end_time
    # @param [Hash] options other query parameters
    # @return [SeriesQuery]
    def query(entity, metric, start_time, end_time, options = {})
      query = SeriesQuery.new @client
      entity = entity.name if entity.is_a? Entity
      metric = metric.name if metric.is_a? Metric
      options.merge! entity: entity, metric: metric, start_time: start_time, end_time: end_time
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
        if s.is_a? Hash
          s = Series.new(s)
        end
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

    # Post json
    # @param [Hash] config - Hash containing url, login and password keys, e.g. {:url => "http://www.example.com:8088/api/v1", :login => "login", :password => "password"}
    # @param [String] payload Body - ready to be parsed by ATSD server
    # @return [Faraday::Response]
    # @raise [APIError]
    def self.post_payload(config,payload)
      url = config[:url]
      login, password = config[:login],config[:password]

      @connection = Faraday.new url do |builder|
        builder.headers['User-Agent'] = "ATSD Ruby Client v#{VERSION}"
        builder.basic_auth login, password
        builder.request :json

        builder.response :errors_handler
        builder.response :json, :content_type => 'application/json'

        builder.adapter Faraday.default_adapter
      end
      response = @connection.post do |req|
        req.body = payload
      end
      response
    end
  end
end