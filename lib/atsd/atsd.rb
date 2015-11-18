require 'atsd/client'
require 'atsd/services/series_service'
require 'atsd/services/properties_service'
require 'atsd/services/alerts_service'
require 'atsd/services/metrics_service'
require 'atsd/services/entities_service'
require 'atsd/services/entity_groups_service'

module ATSD

  # Main class which holds REST client and resource services.
  class ATSD
    # @return [Client] REST API client
    attr_reader :client

    # @option options [String] :url API Endpoint
    # @option options [Hash{Symbol => String}, String] :basic_auth A string 'login:password'
    #   or hash with :login and :password keys
    # @option options [Boolean, Logger] :logger `true` to use default logger, false to disable logging
    #   or a custom logger
    # @yield [Faraday::Connection] Modify middleware in the block
    # @see http://www.rubydoc.info/gems/faraday/0.9.1/Faraday/Connection:initialize for other options
    def initialize(options, &block)
      @client = Client.new(options, &block)
    end

    class << self
      # Defines a new lazy-loaded service
      # @param [Symbol] name the service name
      # @param [Class] type the service's type
      # @!macro [attach] service
      #   @return [$2] the $1 service
      def service(name, type)
        define_method(name) do
          var_name = "@#{name}"
          if instance_variable_defined? var_name
            instance_variable_get var_name
          else
            obj = type.new instance_variable_get('@client')
            instance_variable_set var_name, obj
            obj
          end
        end
      end
    end

    service :series_service, SeriesService
    service :properties_service, PropertiesService
    service :alerts_service, AlertsService
    service :metrics_service, MetricsService
    service :entities_service, EntitiesService
    service :entity_groups_service, EntityGroupsService
  end
end
