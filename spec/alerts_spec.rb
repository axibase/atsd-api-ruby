require 'helpers/shared_client'

include ATSD

RSpec.describe AlertsService do
  include_context 'client'
  subject { AlertsService.new $client }

  context '#query' do
    it 'creates AlertsQuery instance' do
      expect(subject.query).to be_a AlertsQuery
    end

    it 'on execute returns array of Alerts' do
      results = subject.query.execute
      expect(results).to be_a Array
      results.each do |r|
        expect(r).to be_a Alert
      end
    end
  end

  context '#delete' do
    it 'deletes existing alert' do
      results = subject.query.execute
      first = results.first
      subject.delete(first)
      subject.query.execute.each do |alert|
        expect(alert.id).not_to eq first.id
      end
    end
  end

  context '#history_query' do
    it 'returns array of AlertHistory' do
      results = subject.history_query.execute
      expect(results).to be_a Array
      results.each do |r|
        expect(r).to be_a AlertHistory
      end
    end
  end
end