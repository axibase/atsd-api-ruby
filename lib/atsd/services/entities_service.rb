require 'atsd/services/base_service'
require 'atsd/models/entity'
require 'atsd/models/metric'

module ATSD
  # Entities service
  class EntitiesService < BaseService

    # Entities list
    #
    # @option options [Boolean] :active
    #   Filter entities by last insert time. If `active = true`,
    #   only entities with positive `last_insert_time` are included in the response
    # @option options [String] :expression
    #   Use `name` variable for entity name. Use `*` placeholder in `like` expresions
    # @option options [Array<String>] :tags
    #   Specify entity tags to be included in the response
    # @option options [Integer] :limit
    #   Limit response to first N entities, ordered by name.
    # @return [Array<Entity>]
    # @raise [APIError]
    def list(options = {})
      options = options.camelize_keys
      @client.entities_list(options).map do |json|
        Entity.new json
      end
    end

    # Displays entity properties and all tags.
    #
    # @param [String, Entity] entity
    # @return [Entity]
    # @raise [APIError]
    def get(entity)
      Entity.new(@client.entities_get(name_for_entity entity))
    end

    # Create an entity with specified properties and tags
    # or replace an existing entity. This method creates a new
    # entity or replaces an existing entity.
    #
    # @note If only a subset of fields is provided for an existing entity,
    #   the remaining properties will be set to default values and tags
    #   will be deleted.
    #
    # @param [Hash, Entity] entity
    # @return [self]
    # @raise [APIError]
    def create_or_replace(entity)
      entity = Entity.new(entity) if entity.is_a? Hash
      name = name_for_entity entity
      raise ArgumentError unless name
      @client.entities_create_or_replace(name, entity.to_request_hash)
      self
    end

    # Update specified properties and tags for the given entity.
    # @note updates specified properties and tags for an existing entity.
    #   Properties and tags that are not specified are left unchanged.
    #
    # @param [Hash, Entity] entity
    # @return [self]
    # @raise [APIError]
    def update(entity)
      entity = Entity.new(entity) if entity.is_a? Hash
      @client.entities_update(name_for_entity(entity), entity.to_request_hash)
      self
    end

    # Delete the entity. Delete the entity from any Entity Groups that it
    # belongs to. Data collected by the entity will be removed asynchronously
    # in the background.
    #
    # @param [Hash, Entity, String] entity entity or name
    # @return [self]
    # @raise [APIError]
    def delete(entity)
      @client.entities_delete(name_for_entity entity)
      self
    end

    # Returns an array of property types for the entity.
    #
    # @param [String, Hash, Entity] entity
    # @param [Integer, Time] start_time
    #   Return only property types that have been collected after the specified time.
    # @return [Array<String>]
    # @raise [APIError]
    def property_types(entity, start_time = nil)
      start_time = start_time.to_i * 1000 if start_time.is_a? Time
      params = start_time ? { :start_time => start_time } : {}
      @client.entities_property_types(name_for_entity(entity), params)
    end

    # Returns a list of metrics collected by the entity.
    # The list is based on memory cache which is rebuilt on ATSD restart.
    #
    # @param [String, Hash, Entity] entity
    # @option options [Boolean] :active
    #   Filter metrics by last_insert_time. If active = true,
    #   only metrics with positive last_insert_time are included in the response
    # @option options [Array<String>] :tags
    #   Specify metric tags to be included in the response
    # @option options [Integer] :limit
    #   Limit response to first N metrics, ordered by name.
    # @return [Array<Metric>]
    # @raise [APIError]
    def metrics(entity, options = {})
      options = options.camelize_keys
      @client.entities_metrics(name_for_entity(entity), options).map do |json|
        Metric.new json
      end
    end

    private

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