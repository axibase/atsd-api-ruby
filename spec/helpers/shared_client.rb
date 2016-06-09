require 'rspec'
require 'yaml'

require 'atsd'
require 'helpers/vcr_setup'
require 'helpers/middleware_helper'

begin
  test_config = YAML.load_file('spec/config.yml')
rescue Exception => e
  abort(e.message)
end

$client_options = test_config['client_options']
$client = ATSD::Client.new $client_options do |builder|
  builder.insert_after(FaradayMiddleware::ParseJson, VCR::Middleware::Faraday)
  builder.insert_after(FaradayMiddleware::ParseJson, LastEnvMiddleware)
end

RSpec.shared_context 'client' do
  let(:env) { LastEnvMiddleware.last_env }
  around(:each) do |example|
    VCR.use_cassette(example.example_group.metadata[:full_description], :record => :all) do
      example.run
    end
  end
end