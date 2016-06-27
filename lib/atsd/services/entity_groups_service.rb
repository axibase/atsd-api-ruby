require 'atsd/services/base_service'
require 'atsd/models/entity_group'

module ATSD
  class EntityGroupsService < BaseService
    # Entity groups list.
    #
    # @option parameters [String] :expression
    #   Use name variable for entity group name. Use * placeholder
    #   in like expressions
    # @option parameters [Array] :tags
    #   Specify entity group tags to be included in the response
    # @option parameters [Integer] :limit
    #   Limit response to first N entity groups, ordered by name.
    # @return [Array<EntityGroup>]
    # @raise [APIError]
    def list(parameters = {})
      parameters = parameters.camelize_keys
      @client.entity_groups_list(parameters).map do |json|
        EntityGroup.new json
      end
    end

    # Displays entity group properties and all tags.
    #
    # @param [String] entity_group
    # @return [Array<EntityGroup>]
    # @raise [APIError]
    def get(entity_group)
      EntityGroup.new(@client.entity_groups_get(name_for_entity_group entity_group))
    end

    # Create an entity group with specified properties and tags
    # or replace an existing entity group. This method creates
    # a new entity group or replaces an existing entity group.
    #
    # @note If only a subset of fields is provided for an
    #   existing entity group, the remaining properties and
    #   tags will be deleted.
    #
    # @param [Hash, EntityGroup, String] entity_group
    # @return [self]
    # @raise [APIError]
    def create_or_replace(entity_group)
      entity_group = EntityGroup.new(name: entity_group) if entity_group.is_a? String
      entity_group = EntityGroup.new(entity_group) if entity_group.is_a? Hash
      @client.entity_groups_create_or_replace(entity_group.name, entity_group.to_request_hash)
      self
    end

    # Update specified properties and tags for the given entity
    # group. This method updates specified properties and tags
    # for an existing entity group.
    #
    # @note Properties and tags that are not specified are left
    #   unchanged.
    #
    # @param [Hash, EntityGroup] entity_group
    # @return [self]
    # @raise [APIError]
    def update(entity_group)
      entity_group = EntityGroup.new(entity_group) if entity_group.is_a? Hash
      @client.entity_groups_update(entity_group.name, entity_group.to_request_hash)
      self
    end

    # Delete the entity group.
    #
    # @note Entities that are members of the group are retained.
    #
    # @param [String, EntityGroup, Hash] entity_group
    # @return [self]
    # @raise [APIError]
    def delete(entity_group)
      @client.entity_groups_delete(name_for_entity_group(entity_group))
      self
    end

    # Get entities for entity group
    #
    # @param [String, EntityGroup, Hash] entity_group
    # @option parameters [Boolean] :active
    #   Filter entities by last_insert_time. If active = true, only entities
    #   with positive last_insert_time are included in the response
    # @option parameters [String] :expression
    #   Use name variable for entity name. Use * placeholder in like expressions
    # @option parameters [Array] :tags
    #   Specify entity tags to be included in the response
    # @option parameters [Integer] :limit
    #   Limit response to first N entities, ordered by name.
    # @return [Array<Entity>]
    # @raise [APIError]
    def get_entities(entity_group, parameters = {})
      entity_group = name_for_entity_group(entity_group)
      parameters = parameters.camelize_keys
      @client.entity_groups_get_entities(entity_group, parameters).map do |json|
        Entity.new json
      end
    end

    # Add specified entities to entity group.
    #
    # @param [String, EntityGroup, Hash] entity_group
    # @param [Hash, Entity, Array<Hash>, Array<Entity>] entities
    # @option parameters [Boolean] :create_entities
    #   Automatically create new entities from the submitted list
    #   if such entities don’t already exist. Default value: true
    # @return [self]
    # @raise [APIError]
    def add_entities(entity_group, entities, parameters = {})
      entity_group = name_for_entity_group(entity_group)
      parameters = parameters.camelize_keys
      entities = Utils.ensure_array(entities).map do |e|
        e = Entity.new(name: e) if e.is_a? String
        e = Entity.new(e) if e.is_a? Hash
        e = e.to_request_hash
      end
      @client.entity_groups_add_entities(entity_group, entities, parameters)
      self
    end

    # Replace entities in the entity group with the specified collection.
    #
    # @note All existing entities that are not included in the collection
    #   will be removed. If the specified collection is empty, all entities
    #   are removed from the group (replace with empty collection).
    #
    # @param [String, EntityGroup, Hash] entity_group
    # @param [Hash, Entity, Array<Hash>, Array<Entity>] entities
    # @return [self]
    # @raise [APIError]
    def replace_entities(entity_group, entities)
      entity_group = name_for_entity_group(entity_group)
      entities = Utils.ensure_array(entities).map do |e|
        e = Entity.new(name: e) if e.is_a? String
        e = Entity.new(e) if e.is_a? Hash
        e = e.to_request_hash
      end
      @client.entity_groups_replace_entities(entity_group, entities)
      self
    end

    # Delete entities from entity group.
    #
    # @param [String, EntityGroup, Hash] entity_group
    # @param [Hash, Entity, Array<Hash>, Array<Entity>] entities
    # @return [self]
    # @raise [APIError]
    def delete_entities(entity_group, entities)
      entity_group = name_for_entity_group(entity_group)
      entities = Utils.ensure_array(entities).map do |e|
        e = Entity.new(name: e) if e.is_a? String
        e = Entity.new(e) if e.is_a? Hash
        e = e.to_request_hash
      end
      @client.entity_groups_delete_entities(entity_group, entities)
      self
    end

    private

    def name_for_entity_group(entity_group)
      case entity_group
        when String
          entity_group
        when Hash
          entity_group[:name] || entity_group['name']
        when EntityGroup
          entity_group.name? ? entity_group.name : nil
        else
          entity_group.name
      end
    end
  end
end