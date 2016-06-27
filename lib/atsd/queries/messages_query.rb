require 'atsd/queries/base_query'

module ATSD
  # Class for building and executing Messages Query
  # @see https://github.com/axibase/atsd-docs/blob/master/api/data/messages/query.md
  class MessagesQuery < BaseQuery
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

    # @return [Array<Property>]
    def result
      super
    end

    # @return (see #result)
    def execute
      result = @client.messages_query to_request_hash
      @result = result.map { |json| Message.new json }
    end
  end
end

