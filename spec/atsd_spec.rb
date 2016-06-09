require 'rspec'
require 'atsd'

RSpec.describe ATSD do
  let(:atsd) { ATSD.new basic_auth: 'l:p' }

  context '.new' do
    it 'creates new instance of ATSD class' do
      expect(atsd).to be_a ATSD::ATSD
    end
  end

  describe ATSD::ATSD do
    context '.service' do
      it 'creates series service' do
        expect(atsd.series_service).to be_a ATSD::SeriesService
      end

      it 'creates properties service' do
        expect(atsd.properties_service).to be_a ATSD::PropertiesService
      end

      it 'creates alerts service' do
        expect(atsd.alerts_service).to be_a ATSD::AlertsService
      end

      it 'creates metrics service' do
        expect(atsd.metrics_service).to be_a ATSD::MetricsService
      end

      it 'creates entities service' do
        expect(atsd.entities_service).to be_a ATSD::EntitiesService
      end

      it 'creates entity groups service' do
        expect(atsd.entity_groups_service).to be_a ATSD::EntityGroupsService
      end
    end
  end
end
