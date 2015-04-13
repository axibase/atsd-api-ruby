require 'vcr'
require 'helpers/json_pretty'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/vcr_cassettes'
  c.cassette_serializers[:json_pretty] = VCR::Cassette::Serializers::JSONPretty
  c.default_cassette_options = {
      match_requests_on: [:method, :path, :query, :body],
      record: :new_episodes,
      serialize_with: :json_pretty
  }
end