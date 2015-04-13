require 'atsd/services/base_service'
require 'atsd/models/metric'
require 'atsd/models/entity'

module ATSD
  class MetricsService < BaseService
    # Metrics list.
    #
    # @option parameters [String] :expression
    #   Use name variable for metric name. Use * placeholder
    #   in like expressions
    # @option parameters [Boolean] :active
    #   Filter metrics by last_insert_time. If active = true,
    #   only metrics with positive last_insert_time are included in the response
    # @option parameters [Array] :tags
    #   Specify metric tags to be included in the response
    # @option parameters [Integer] :limit
    #   Limit response to first N metrics, ordered by name.
    # @return [Array<Metric>]
    # @raise [APIError]
    def list(parameters = {})
      parameters = parameters.camelize_keys
      @client.metrics_list(parameters).map do |json|
        Metric.new json
      end
    end

    # Displays metric properties and its tags.
    #
    # @param [String] metric
    # @return [Array<Metric>]
    # @raise [APIError]
    def get(metric)
      Metric.new(@client.metrics_get(name_for_metric metric))
    end

    # Create a metric with specified properties and tags or replace
    # an existing metric. This method creates a new metric or replaces
    # an existing metric.
    #
    # @note If only a subset of fields is provided for an existing metric,
    #   the remaining properties and tags will be deleted.
    #
    # @param [Hash, Metric, String] metric
    # @return [self]
    # @raise [APIError]
    def create_or_replace(metric)
      metric = Metric.new(name: metric) if metric.is_a? String
      metric = Metric.new(metric) if metric.is_a? Hash
      @client.metrics_create_or_replace(metric.name, metric.to_request_hash)
      self
    end

    # Update specified properties and tags for the given metric.
    # This method updates specified properties and tags for an existing metric.
    #
    # @note Properties and tags that are not specified are left unchanged.
    #
    # @param [Hash, Metric] metric
    # @return [self]
    # @raise [APIError]
    def update(metric)
      metric = Metric.new(metric) if metric.is_a? Hash
      @client.metrics_update(metric.name, metric.to_request_hash)
      self
    end

    # Delete the metric. Data collected for the metric will be removed
    # asynchronously in the background.
    #
    # @param [String, Metric, Hash] metric
    # @return [self]
    # @raise [APIError]
    def delete(metric)
      @client.metrics_delete(name_for_metric(metric))
      self
    end

    # Returns a list of unique series tags for the metric. The list is
    # based on data stored on disk for the last 24 hours.
    #
    # @param [Hash, Metric, String] metric
    # @param [Hash, Entity, String] entity
    # @return [Array<Entity>]
    # @raise [APIError]
    def entity_and_tags(metric, entity = nil)
      metric = name_for_metric(metric)
      params = {}
      params[:entity] = name_for_entity(entity) if entity
      result = @client.metrics_entity_and_tags(metric, params)
      result.map { |json| Entity.new json }
    end

    private

    def name_for_metric(metric)
      case metric
        when String
          metric
        when Hash
          metric[:name] || metric['name']
        when Metric
          metric.name? ? metric.name : nil
        else
          metric.name
      end
    end

    def name_for_entity(entity)
      case entity
        when String
          entity
        when Hash
          entity[:name] || entity['name']
        when Entity
          entity.name? ? entity.name : nil
        else
          entity.name
      end
    end
  end
end