require 'atsd/services/base_service'
require 'atsd/queries/messages_query'
require 'atsd/models/message'
require 'atsd/models/entity'

module ATSD
  class MessagesService < BaseService
    # Create query builder for messages.
    #
    # @param [String, Entity] entity
    # @param [Hash] options other query parameters
    # @return [MessagesQuery]
    def query(entity, options = {})
      query = MessagesQuery.new @client
      entity = entity.name if entity.is_a? Entity
      options.merge! entity: entity
      options.each { |option, value| query[option] = value }
      query
    end

    # Insert messages.
    #
    # @param [Array<Message, Hash>, Message, Hash] messages
    # @return [self]
    # @raise [APIError]
    def insert(messages)
      messages = Utils.ensure_array(messages).map do |s|
        s = Message.new(s) if s.is_a? Hash
        s.to_request_hash
      end
      @client.messages_insert messages
      self
    end

    # Retrieve message counters for the specified filters as series.
    #
    # @param [Hash] options parameters
    # @return [self]
    # @raise [APIError]
    def stats_query(options)
      options[:metric] = 'message-count'
      options = Utils.ensure_array(options).map do |s|
        s = Message.new(s) if s.is_a? Hash
        s.to_request_hash
      end
      result = @client.messages_stat_query(options)
      result.map { |json| Series.new json }
    end
  end
end