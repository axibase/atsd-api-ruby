require 'atsd/middleware/errors_handler'
require 'active_support/core_ext/hash/keys'
require 'uri'

module ATSD

  # HTTP(S) Client for Axibase Time Series Database. Implements all REST methods
  # of the API in a straightforward manner.
  class Client

    # @return [Faraday::Connection] faraday connection object
    attr_reader :connection

    # @return [Logger] logger to use
    attr_reader :logger

    # See {ATSD#initialize ATSD.new}
    def initialize(options, &block)
      options = options.symbolize_keys
      login, password = extract_basic_auth(options)
      @logger = extract_logger(options)
      url = options.delete(:url)
      @connection = Faraday.new url, options do |builder|
        builder.headers['User-Agent'] = "ATSD Ruby Client v#{VERSION}"
        builder.basic_auth login, password
        builder.request :json

        builder.response :errors_handler
        builder.response :json, :content_type => 'application/json'
        builder.response :logger, @logger, :bodies => true if @logger

        builder.adapter Faraday.default_adapter
      end

      if block_given?
        block.arity > 0 ? yield(@connection.builder) : @connection.builder.instance_eval(&block)
      end
      true
    end

    # Query time series
    #
    # @param [Hash, Array<Hash>] queries query or array of queries
    # @return [Array<Hash>] time series
    # @raise [APIError]
    # @see https://github.com/axibase/atsd-docs/blob/master/api/data/series/query.md for details
    def series_query(queries)
      response = @connection.post 'series/query', Utils.ensure_array(queries)
      response.body
    end

    # Retrieve series values for the specified entity, metric, and optional series tags in CSV and JSON format
    #
    # @param [String] format
    # @param [String] entity
    # @param [String] metric
    # @param [Hash] parameters other query parameters
    # @return [Array<Hash>] time series
    # @raise [APIError]
    # @see https://github.com/axibase/atsd-docs/blob/master/api/data/series/url-query.md for details
    def series_url_query(format, entity, metric, parameters ={})
      url = "series/#{CGI.escape(format)}/#{CGI.escape(entity)}/#{CGI.escape(metric)}?"
      response = @connection.get url, parameters
      response.body
    end

    # Insert time series
    #
    # @param [Hash, Array<Hash>] series series or array of series
    # @return true
    # @raise [APIError]
    # @see https://github.com/axibase/atsd-docs/blob/master/api/data/series/insert.md for details
    def series_insert(series)
      @connection.post 'series/insert', Utils.ensure_array(series)
      true
    end

    # Series CSV: Insert
    #
    # @param [String] entity
    # @param [String] data Payload - CSV containing time column and one or multiple metric columns.
    #   - Separator must be comma.
    #   - Time must be specified in Unix milliseconds.
    #   - Time column must be first, name of the time column could be arbitrary.
    # @param [Hash] tags tag=value hash
    # @return [true]
    # @raise [APIError]
    # @see https://github.com/axibase/atsd-docs/blob/master/api/data/series/csv-insert.md for details
    def series_csv_insert(entity, data, tags = {})
      request = @connection.build_request(:post) do |req|
        req.url("series/csv/#{CGI.escape(entity)}", tags)
        req.headers["Content-Type"] = 'text/csv'
        req.body = data
      end

      @connection.builder.build_response(@connection, request)
      true
    end

    # Query messages
    #
    # @param [Hash, Array<Hash>] queries query or array of queries
    # @return [Array<Hash>] array of messages
    # @raise [APIError]
    # @see https://github.com/axibase/atsd-docs/blob/master/api/data/messages/query.md for details
    def messages_query(queries = nil)
      response = @connection.post 'messages/query', Utils.ensure_array(queries)
      response.body
    end

    # Insert messages
    #
    # @param [Hash, Array<Hash>] messages message or array of messages
    # @return true
    # @raise [APIError]
    # @see https://github.com/axibase/atsd-docs/blob/master/api/data/messages/insert.md for details
    def messages_insert(messages)
      @connection.post 'messages/insert', Utils.ensure_array(messages)
      true
    end

    # Statistics query
    #
    # @param [Hash] parameters
    # @return [Array<Hash>] time series
    # @raise [APIError]
    # @see https://github.com/axibase/atsd-docs/blob/master/api/data/messages/stats-query.md for details
    def messages_stat_query(parameters = {})
      print parameters
      response = @connection.post 'messages/stats/query', Utils.ensure_array(parameters)
      response.body
    end

    # Query properties
    #
    # @param [Hash, Array<Hash>] queries query or array of queries
    # @return [Array<Hash>] array of properties
    # @raise [APIError]
    # @see https://github.com/axibase/atsd-docs/blob/master/api/data/properties/query.md for details
    def properties_query(queries = nil)
      response = @connection.post 'properties/query', Utils.ensure_array(queries)
      response.body
    end

    # Returns properties for entity and type.
    #
    # @param [String] entity
    # @param [String] type
    # @return [Array<Hash>] array of properties
    # @raise [APIError]
    # @see https://github.com/axibase/atsd-docs/blob/master/api/data/properties/url-query.md for details
    def properties_for_entity_and_type(entity, type)
      response = @connection.get "properties/#{CGI.escape(entity)}/types/#{CGI.escape(type)}"
      response.body
    end

    # Returns array of property types for the entity.
    #
    # @param [String] entity
    # @return [Array<Hash>] array of properties
    # @raise [APIError]
    # @see https://github.com/axibase/atsd-docs/blob/master/api/data/properties/type-query.md for details
    def properties_for_entity(entity)
      response = @connection.get "properties/#{CGI.escape(entity)}/types"
      response.body
    end

    # Insert properties
    #
    # @param [Hash, Array<Hash>] properties property or array of properties
    # @return true
    # @raise [APIError]
    # @see https://github.com/axibase/atsd-docs/blob/master/api/data/properties/insert.md for details
    def properties_insert(properties)
      @connection.post 'properties/insert', Utils.ensure_array(properties)
      true
    end

    # Delete an array of properties for entity, type, and optionally for specified keys
    #
    # @param [Hash, Array<Hash>] properties
    # @return true
    # @raise [APIError]
    # @see https://github.com/axibase/atsd-docs/blob/master/api/data/properties/delete.md for details
    def properties_delete(properties)
      @connection.post 'properties/delete', Utils.ensure_array(properties)
    end

    # Query alerts
    #
    # @param [Hash, Array<Hash>] queries query or array of queries
    # @return [Array<Hash>] alerts
    # @raise [APIError]
    # @see https://github.com/axibase/atsd-docs/blob/master/api/data/alerts/query.md for details
    def alerts_query(queries = nil)
      response = @connection.post 'alerts/query', Utils.ensure_array(queries)
      response.body
    end

    # (De-)acknowledge alerts
    #
    # @param [Hash, Array<Hash>] actions action or array of actions
    # @return [true]
    # @raise [APIError]
    # @see https://github.com/axibase/atsd-docs/blob/master/api/data/alerts/update.md for details
    def alerts_update(actions)
      @connection.post 'alerts/update', Utils.ensure_array(actions)
      true
    end

    # Delete alerts
    #
    # @param [Hash, Array<Hash>] actions action or array of actions
    # @return [true]
    # @raise [APIError]
    # @see https://github.com/axibase/atsd-docs/blob/master/api/data/alerts/delete.md for details
    def alerts_delete(actions)
      @connection.post 'alerts/delete', Utils.ensure_array(actions)
      true
    end

    # Alerts history query
    #
    # @param [Hash, Array<Hash>] queries query or array of queries
    # @return [Array<Hash>] history records
    # @raise [APIError]
    # @see https://github.com/axibase/atsd-docs/blob/master/api/data/alerts/history-query.md for details
    def alerts_history_query(queries = nil)
      response = @connection.post 'alerts/history/query', Utils.ensure_array(queries)
      response.body
    end

    # Metrics list.
    #
    # @param [Hash] parameters
    # @return [Array<Hash>]
    # @raise [APIError]
    # @see https://github.com/axibase/atsd-docs/blob/master/api/meta/metric/list.md for details
    def metrics_list(parameters = {})
      response = @connection.get 'metrics', parameters
      response.body
    end

    # Displays metric properties and its tags.
    #
    # @param [String] metric
    # @return [Hash]
    # @raise [APIError]
    # @see https://github.com/axibase/atsd-docs/blob/master/api/meta/metric/get.md for details
    def metrics_get(metric)
      response = @connection.get "metrics/#{CGI.escape(metric)}"
      response.body
    end

    # Create a metric with specified properties and tags or replace an existing metric.
    # This method creates a new metric or replaces an existing metric.
    #
    # @note If only a subset of fields is provided for an existing metric,
    #   the remaining properties and tags will be deleted.
    #
    # @param [String] metric
    # @param [Hash] body
    # @return [true]
    # @raise [APIError]
    # @see https://github.com/axibase/atsd-docs/blob/master/api/meta/metric/create-or-replace.md for details
    def metrics_create_or_replace(metric, body)
      @connection.put "metrics/#{CGI.escape(metric)}", body
      true
    end

    # Update specified properties and tags for the given metric.
    # This method updates specified properties and tags for an existing metric.
    #
    # @note Properties and tags that are not specified are left unchanged.
    #
    # @param [String] metric
    # @param [Hash] body
    # @return [true]
    # @raise [APIError]
    # @see https://github.com/axibase/atsd-docs/blob/master/api/meta/metric/update.md for details
    def metrics_update(metric, body)
      @connection.patch "metrics/#{CGI.escape(metric)}", body
      true
    end

    # Delete the metric. Data collected for the metric will be removed
    # asynchronously in the background.
    #
    # @param [String] metric
    # @return [true]
    # @raise [APIError]
    # @see https://github.com/axibase/atsd-docs/blob/master/api/meta/metric/delete.md for details
    def metrics_delete(metric)
      @connection.delete "metrics/#{CGI.escape(metric)}"
      true
    end

    # Returns a list of series for the metric.
    # Each series is identified with metric name, entity name, and optional series tags.
    #
    # @param [String] metric
    # @param [Hash] parameters
    # @return [Array]
    # @raise [APIError]
    # @see https://github.com/axibase/atsd-docs/blob/master/api/meta/metric/series.md for details
    def metrics_series(metric, parameters = {})
      response = @connection.get "metrics/#{CGI.escape(metric)}/series", parameters
      response.body
    end

    # List of entities
    #
    # @param [Hash] parameters
    # @return [Array<Hash>]
    # @raise [APIError]
    # @see https://github.com/axibase/atsd-docs/blob/master/api/meta/entity/list.md for details
    def entities_list(parameters = {})
      response = @connection.get 'entities', parameters
      response.body
    end

    # Entity details
    #
    # @param [String] entity
    # @return [Hash]
    # @raise [APIError]
    # @see https://github.com/axibase/atsd-docs/blob/master/api/meta/entity/get.md for details
    def entities_get(entity)
      response = @connection.get "entities/#{CGI.escape(entity)}"
      response.body
    end

    # Create or replace entity.
    #
    # @param [String] entity
    # @param [Hash] body
    # @return [true]
    # @raise [APIError]
    # @see https://github.com/axibase/atsd-docs/blob/master/api/meta/entity/create-or-replace.md for details
    def entities_create_or_replace(entity, body)
      @connection.put "entities/#{CGI.escape(entity)}", body
      true
    end

    # Update entity.
    #
    # @param [String] entity
    # @param [Hash] body
    # @return [true]
    # @raise [APIError]
    # @see https://github.com/axibase/atsd-docs/blob/master/api/meta/entity/update.md for details
    def entities_update(entity, body)
      @connection.patch "entities/#{CGI.escape(entity)}", body
      true
    end

    # Delete entity.
    #
    # @param [String] entity
    # @return [true]
    # @raise [APIError]
    # @see https://github.com/axibase/atsd-docs/blob/master/api/meta/entity/delete.md for details
    def entities_delete(entity)
      @connection.delete "entities/#{CGI.escape(entity)}"
      true
    end

    # Entity groups entity.
    #
    # @param [String] entity
    # @return [Array]
    # @raise [APIError]
    # @see https://github.com/axibase/atsd-docs/blob/master/api/meta/entity/entity-groups.md for details
    def entities_entity_groups(entity, parameters = {})
      response = @connection.get "entities/#{CGI.escape(entity)}/groups", parameters
      response.body
    end

    # Property types for entity
    #
    # @param [String] entity
    # @param [Hash] parameters
    # @return [Array]
    # @raise [APIError]
    # @see https://github.com/axibase/atsd-docs/blob/master/api/meta/entity/property-types.md for details
    def entities_property_types(entity, parameters = {})
      response = @connection.get "entities/#{CGI.escape(entity)}/property-types", parameters
      response.body
    end

    # Metrics for entity
    #
    # @param [String] entity
    # @param [Hash] parameters
    # @return [Array]
    # @raise [APIError]
    # @see https://github.com/axibase/atsd-docs/blob/master/api/meta/entity/metrics.md for details
    def entities_metrics(entity, parameters = {})
      response = @connection.get "entities/#{CGI.escape(entity)}/metrics", parameters
      response.body
    end

    # Entity groups list.
    #
    # @param [Hash] parameters
    # @return [Array]
    # @raise [APIError]
    # @see https://github.com/axibase/atsd-docs/blob/master/api/meta/entity-group/list.md for details
    def entity_groups_list(parameters = {})
      response = @connection.get 'entity-groups', parameters
      response.body
    end

    # Entity group info
    #
    # @param [String] entity_group
    # @return [Hash]
    # @raise [APIError]
    # @see https://github.com/axibase/atsd-docs/blob/master/api/meta/entity-group/get.md for details
    def entity_groups_get(entity_group)
      response = @connection.get "entity-groups/#{CGI.escape(entity_group)}"
      response.body
    end

    # Create or replace entity group.
    #
    # @param [String] entity_group
    # @param [Hash] body
    # @return [true]
    # @raise [APIError]
    # @see https://github.com/axibase/atsd-docs/blob/master/api/meta/entity-group/create-or-replace.md for details
    def entity_groups_create_or_replace(entity_group, body)
      @connection.put "entity-groups/#{CGI.escape(entity_group)}", body
      true
    end

    # Update entity group.
    #
    # @param [String] entity_group
    # @param [Hash] body
    # @return [true]
    # @raise [APIError]
    # @see https://github.com/axibase/atsd-docs/blob/master/api/meta/entity-group/update.md for details
    def entity_groups_update(entity_group, body)
      @connection.patch "entity-groups/#{CGI.escape(entity_group)}", body
      true
    end

    # Delete entity group.
    #
    # @param [String] entity_group
    # @return [true]
    # @raise [APIError]
    # @see https://github.com/axibase/atsd-docs/blob/master/api/meta/entity-group/delete.md for details
    def entity_groups_delete(entity_group)
      @connection.delete "entity-groups/#{CGI.escape(entity_group)}"
      true
    end

    # List entity group entities.
    #
    # @param [String] entity_group
    # @param [Hash] parameters
    # @return [Array]
    # @raise [APIError]
    # @see https://github.com/axibase/atsd-docs/blob/master/api/meta/entity-group/get-entities.md for details
    def entity_groups_get_entities(entity_group, parameters = {})
      response = @connection.get "entity-groups/#{CGI.escape(entity_group)}/entities", parameters
      response.body
    end

    # Add entities to entity group.
    #
    # @param [String] entity_group
    # @param [Array] entities
    # @param [Hash] parameters
    # @return [true]
    # @raise [APIError]
    # @see https://github.com/axibase/atsd-docs/blob/master/api/meta/entity-group/add-entities.md for details
    def entity_groups_add_entities(entity_group, entities, parameters = {})
      @connection.patch "entity-groups/#{CGI.escape(entity_group)}/entities", [
          parameters.merge(:action => 'add',
                           :createEntities => true,
                           :entities => entities)
      ]
      true
    end

    # Replace entities in entity group.
    #
    # @param [String] entity_group
    # @param [Array] entities
    # @param [Hash] parameters
    # @return [true]
    # @raise [APIError]
    # @see https://github.com/axibase/atsd-docs/blob/master/api/meta/entity-group/replace-entities.md for details
    def entity_groups_replace_entities(entity_group, entities, parameters = {})
      @connection.put "entity-groups/#{CGI.escape(entity_group)}/entities", entities
      true
    end

    # Delete entities in entity group.
    #
    # @param [String] entity_group
    # @param [Array] entities
    # @return [true]
    # @raise [APIError]
    # @see https://github.com/axibase/atsd-docs/blob/master/api/meta/entity-group/delete-entities.md for details
    def entity_groups_delete_entities(entity_group, entities)
      @connection.patch "entity-groups/#{CGI.escape(entity_group)}/entities", [
          {:action => 'delete', :entities => entities}
      ]
      true
    end

    private

    def extract_basic_auth(options)
      auth = options.delete :basic_auth
      case auth
        when String
          auth.split(':', 2)
        when Hash
          return auth[:login], auth[:password]
        else
          raise ArgumentError, 'Bad login/password specification'
      end
    end

    def extract_logger(options)
      logger = options.delete :logger
      case logger
        when true
          require 'logger'
          ::Logger.new(STDOUT)
        when false
          nil
        else
          logger
      end
    end
  end
end

