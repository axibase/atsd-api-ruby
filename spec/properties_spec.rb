require 'helpers/shared_client'

include ATSD

entity_name = 'prop-test-entity'
RSpec.describe PropertiesService do
  include_context 'client'
  subject { PropertiesService.new $client }

  let(:entity) { entity_name }
  let(:type) { 'prop_test_type' }
  let(:start_date) { '2015-04-01T10:59:34.000Z' }
  let(:end_date) { Time.now }
  let(:key) { { 'system' => 'system_name', 'user' => 'user_name' } }
  let(:tags) { { 'tag1' => 'tagvalue1', 'tag2' => 'tagvalue2' } }


  before(:all) do
    VCR.use_cassette('PropertiesServiceAll') do
      entities = EntitiesService.new $client
      entities.create_or_replace :name => entity_name
    end
  end

  after(:all) do
    VCR.use_cassette('PropertiesServiceAll') do
      entities = EntitiesService.new $client
      entities.delete entity_name
    end
  end

  context '#delete' do
    it 'deletes existing property' do
      type = 'other_type'
      property = Property.new entity: entity,
                              type: type,
                              key: key,
                              tags: tags
      subject.insert(property)
      subject.delete(property)
      query = subject.query(entity, type, :start_date => start_date, :end_date => end_date)
      expect(query.execute.count).to eq 0
    end
  end

  context '#query' do
    it 'create PropertiesQuery instance' do
      query = subject.query(entity, type)
      expect(query).to be_a PropertiesQuery
      expect(query[:entity]).to eq entity
      expect(query[:type]).to eq type
    end

    it 'understand Entity object' do
      entity_obj = Entity.new :name => entity
      query = subject.query entity_obj, type
      expect(query[:entity]).to eq(entity)
      expect(query).to be_a PropertiesQuery
    end

    it 'return correct properties on execute()' do
      prop = Property.new entity: entity,
                          type: type,
                          key: key,
                          tags: tags
      subject.insert(prop)
      query = subject.query(entity, type, :start_date => start_date, :end_date => end_date)
      response = query.execute
      expect(response).to be_a Array
      expect(response.count).to eq 1
      remote = response[0]
      expect(remote.entity).to eq prop.entity
      expect(remote.type).to eq prop.type
      expect(remote['key']).to eq prop[:key]
      expect(remote.tags).to eq prop.tags
      subject.delete(remote)
    end
  end

  context '#insert' do
    it 'send Hash to ATSD' do
      property = {
          entity: entity,
          type: type,
          key: key,
          tags: tags,
          date: start_date
      }
      expect(subject.insert(property)).to eq(subject) # also check method chaining
      query = subject.query(entity, type, :start_date => start_date, :end_date => end_date)
      remote = query.execute
      remote = remote[0]
      expect(remote.entity).to eq entity
      expect(remote.type).to eq type
      subject.delete(remote)
    end

    it 'raise error on empty data' do
      property = Property.new
      expect { subject.insert property }.to raise_exception(ATSD::APIError)
    end
  end

end
