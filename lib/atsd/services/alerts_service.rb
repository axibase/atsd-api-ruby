require 'atsd/services/base_service'
require 'atsd/models/alert'
require 'atsd/models/alert_history'
require 'atsd/queries/alerts_query'
require 'atsd/queries/alerts_history_query'

module ATSD
  class AlertsService < BaseService
    # Create query builder for alerts.
    #
    # @param [Hash] options query parameters
    # @return [AlertsQuery]
    def query(options = {})
      query = AlertsQuery.new @client
      options.each { |option, value| query[option] = value }
      query
    end

    # Change acknowledgement status of the specified alerts.
    #
    # @param [Array<Hash, Alert>, Hash, Alert] alerts
    # @return [self]
    # @raise [APIError]
    def update(alerts)
      alerts = Utils.ensure_array(alerts).map do |alert|
        { :id => id_for_alert(alert),
          :acknowledged => acknowledged_for_alert(alert)}
      end
      return if alerts.count == 0
      @client.alerts_update alerts
    end

    # Delete alerts
    #
    # @param [Array<Hash, Alert>, Hash, Alert] alerts
    # @return [self]
    # @raise [APIError]
    def delete(alerts)
      alerts = Utils.ensure_array(alerts).map do |alert|
        { :id => id_for_alert(alert) }
      end
      return if alerts.count == 0
      @client.alerts_delete alerts
    end

    # Create query builder for alert history.
    #
    # @param [Hash] options query parameters
    # @return [AlertsHistoryQuery]
    def history_query(options = {})
      query = AlertsHistoryQuery.new @client
      options.each { |option, value| query[option] = value }
      query
    end

    private

    def id_for_alert(alert)
      case alert
        when Integer
          alert
        when Alert
          alert.id
        when Hash
          alert[:id] || alert['id']
        else
          alert.id
      end
    end

    def acknowledged_for_alert(alert)
      case alert
        when Alert
          alert.acknowledged
        when Hash
          alert[:acknowledged] || alert['acknowledged']
        else
          false
      end
    end
  end
end