require 'helpers/shared_client'

include ATSD

entity_name = 'prop_test_entity'
RSpec.describe PropertiesService do
  include_context 'client'
  subject { PropertiesService.new $client }

  let(:entity) { entity_name }
  let(:type) { 'prop_test_type' }
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
      query = subject.query(entity, type)
      response = query.execute
      expect(response).to be_a Array
      expect(response.count).to eq 1
      remote = response[0]
      expect(remote.entity).to eq prop.entity
      expect(remote.type).to eq prop.type
      expect(remote[:key]).to eq prop[:key]
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
          tags: tags
      }
      expect(subject.insert(property)).to eq(subject) # also check method chaining
      query = subject.query(entity, type)
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

  context '#delete' do
    it 'deletes existing property' do
      type = 'other_type'
      property = Property.new entity: entity,
                              type: type,
                              key: key,
                              tags: tags
      subject.insert(property)
      subject.delete(property)
      query = subject.query(entity, type)
      expect(query.execute.count).to eq 0
    end
  end

  context '#delete_match' do
    it 'deletes existing properties' do
      time = 10000000000000
      type = "some_other_type"
      property = Property.new entity: entity,
                               type: type,
                               key: key,
                               tags: tags,
                               timestamp: time
      subject.insert(property)
      query = subject.query(entity, type)
      expect(query.end_time(time + 10000).execute.count).to eq 1
      subject.delete_match({type: type, createdBeforeTime: time + 1000})
      expect(query.end_time(time + 10001).execute.count).to eq 0 # create slightly different query so VCR doesn't cache it
    end
  end
end
