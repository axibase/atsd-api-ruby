require 'atsd/queries/base_query'

module ATSD
  # Class for building and executing Properties Query
  # @see https://axibase.com/atsd/api/#properties:-query
  class PropertiesQuery < BaseQuery
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
      result = @client.properties_query to_request_hash
      @result = result.map { |json| Property.new json }
    end
  end
end

