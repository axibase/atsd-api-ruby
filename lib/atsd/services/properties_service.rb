require 'atsd/services/base_service'
require 'atsd/queries/properties_query'
require 'atsd/models/property'
require 'atsd/models/entity'

module ATSD
  class PropertiesService < BaseService
    # Create query builder for properties.
    #
    # @param [String, Entity] entity
    # @param [String] type
    # @param [Hash] options other query parameters
    # @return [PropertiesQuery]
    def query(entity, type, options = {})
      query = PropertiesQuery.new @client
      entity = entity.name if entity.is_a? Entity
      options.merge! entity: entity, type: type
      options.each { |option, value| query[option] = value }
      query
    end

    # Insert properties.
    #
    # @param [Array<Property, Hash>, Property, Hash] properties
    # @return [self]
    # @raise [APIError]
    def insert(properties)
      properties = Utils.ensure_array(properties).map do |s|
        s = Property.new(s) if s.is_a? Hash
        s.to_request_hash
      end
      @client.properties_insert properties
      self
    end

    # Returns an array of property types for the entity.
    #
    # @param [String] entity
    # @return [self]
    # @raise [APIError]
    def type_query(entity)
      @client.properties_for_entity(entity)
    end

    # Retrieve property records for the specified entity and type.
    #
    # @param [String] entity
    # @param [String] type
    # @return [self]
    # @raise [APIError]
    def url_query(entity, type)
      @client.properties_for_entity_and_type(entity,type)
    end

    # Delete properties.
    #
    # @param [Array<Property, Hash>, Property, Hash] properties
    # @return [self]
    # @raise [APIError]
    def delete(properties)
      properties = Utils.ensure_array(properties).map do |s|
        s = s.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
        s = Property.new(s) if s.is_a? Hash
        s.to_request_hash.select { |k, v| [:entity, :type, :key].include? k }
      end
      @client.properties_delete(properties)
      self
    end
  end
end