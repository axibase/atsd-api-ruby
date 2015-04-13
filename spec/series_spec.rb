require 'helpers/shared_client'

include ATSD

RSpec.describe SeriesService do
  include_context 'client'
  subject { SeriesService.new $client }

  let(:entity) { 'ubuntu' }
  let(:metric) { 'meminfo.active' }
  let(:start_time) { 1427885974000 }
  let(:end_time) { 1427885975000 }
  let(:data) { [ t: 1427885974000, v: 1  ] }
  let(:tags) { { :tag1 => 'value1' } }

  context '#query' do
    let(:query) { subject.query entity, metric }

    it 'create SeriesQuery instance' do
      expect(query).to be_a SeriesQuery
    end

    it 'return Array of Series on execute()' do
      response = query.execute
      expect(response).to be_a Array
      expect(response[0]).to be_a Series
    end

    it 'understand Entity and Metric objects' do
      entity_obj = Entity.new :name => entity
      metric_obj = Metric.new :name => metric
      query = subject.query entity_obj, metric_obj
      expect(query[:entity]).to eq(entity)
      expect(query[:metric]).to eq(metric)
    end
  end

  context '#insert' do
    it 'send Hash to ATSD' do
      series = { entity: entity, metric: metric, data: data  }
      expect(subject.insert(series)).to eq(subject) # also check method chaining
    end

    it 'send Series to ATSD' do
      series = Series.new
      series.entity = entity
      series.metric = metric
      series.data = [ t: start_time, v: 1]
      subject.insert(series)
    end

    it 'raise error on empty data' do
      series = Series.new
      expect { subject.insert series }.to raise_exception(ATSD::APIError)
    end

    it 'support multiple series' do
      series = { entity: entity, metric: metric, data: data  }
      subject.insert([series, series, series])
    end
  end

  context "#csv_insert" do
    let (:data) { "time,value\n11428654811000,53142\n1428654812000,53342\n428654813000,53242\n" }
    it 'correctly build request' do
      tags = {:q => 'ats', :w => 'vcx'}
      subject.csv_insert(entity, data, tags)
      expect(env.url.path).to eq "/api/v1/series/csv/#{entity}"
      expect(env.url.query).to eq 'q=ats&w=vcx'
      expect(env.method).to eq :post
      expect(env.request_headers["Content-Type"]).to eq 'text/csv'
    end
  end

  describe SeriesQuery do
    context '#result' do
      it 'call execute if necessary' do
        query = SeriesQuery.new $client
        query.entity(entity).metric(metric)
        expect(query.result).to be_truthy
      end
    end

    context '#execute_with' do
      it 'set "request_id" if necessary' do
        query = SeriesQuery.new $client
        query.entity(entity).
            metric(metric).
            start_time(start_time).
            end_time(end_time)
        query2 = query.dup.
            start_time(query[:start_time] + 100).
            end_time(query[:end_time] + 100)
        result = query.execute_with(query2)
        expect(query[:request_id]).to be_truthy
        expect(query2[:request_id]).to be_truthy
        expect(query.result).to be_truthy
        expect(query2.result).to be_truthy
        expect(result.count).to eq(query.result.count + query2.result.count)
      end
    end
  end
end
