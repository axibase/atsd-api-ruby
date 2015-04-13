require 'helpers/shared_client'

RSpec.describe ATSD::Client do
  include_context 'client'

  context '#connection' do
    it 'creates correct url prefix' do
      expect($client.connection.url_prefix).to eq(URI($client_options['url']))
    end

    it 'sets authorization header' do
      expect($client.connection.headers['Authorization']).to be_truthy
    end
  end

  context 'Middleware' do
    it 'throws APIError on error' do
      expect { $client.connection.get '404_not_found' }.to raise_exception ATSD::APIError do |error|
        expect(error.status).to eq 404
      end
    end
  end

  describe "API Methods" do
    let(:request_body) { {
        entity: 'ubuntu',
        metric: 'meminfo.active',
        startTime: 1427885974000,
        endTime: 1427885975000
    } }

    context "#series_query" do
      let(:response) { $client.series_query request_body }

      it 'send POST request to "series"' do
        response
        expect(env.method).to eq(:post)
        expect(env.url.path).to eq('/api/v1/series')
      end

      it 'returns Array of Hashes' do
        expect(response).to be_a Array
        expect(response[0]).to be_a Hash
      end
    end

    context "#series_insert" do
      let(:series) { {
          entity: 'ubuntu',
          metric: 'meminfo.active',
          data: [ { t: 1, v: 1} ]
      } }

      it 'inserts single series' do
        expect($client.series_insert series).to be_truthy
      end
    end
  end
end