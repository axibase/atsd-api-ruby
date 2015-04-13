require 'helpers/shared_client'

include ATSD

RSpec.describe EntitiesService do
  include_context 'client'
  subject { EntitiesService.new $client }

  context '#list' do
    it 'return an Array<Entity>' do
      result = subject.list
      expect(result).to be_a Array
      result.each { |e| expect(e).to be_a Entity  }
    end

    # TODO: More examples with filters
  end

  context '#get' do
    let(:name) { 'rspectest' }
    let(:enabled) { true }
    let(:tags) { {
        'tag1' => 'value1',
        'tag2' => 'value2',
        'tag3' => 'value3',
    } }

    it 'return Entity if there is one' do
      subject.create_or_replace name: name,
                                enabled: enabled,
                                tags: tags
      entity = subject.get(name)
      expect(entity).to be_a Entity
      expect(entity.name).to eq name
      expect(entity.enabled).to eq enabled
      expect(entity.tags).to eq tags
      subject.delete(name)
    end

    it 'raise error if there is none' do
      expect { subject.get('nonexistent_entity') }.to raise_exception(APIError) do |error|
        expect(error.status).to eq 404
      end
    end
  end

  context '#create_or_replace' do
    it 'raises error on empty entity' do
      expect { subject.create_or_replace(ATSD::Entity.new) }.to raise_exception
    end

    it 'creates valid entity' do
      entity = Entity.new name: 'test_entity'
                          # enabled: false,
                          # tags: { 'tag' => 'value' }
      # commented out due to strange ATSD behaviour
      subject.create_or_replace(entity)
      remote = subject.get(entity.name)
      expect(remote.name).to eq entity.name
      # expect(remote.enabled).to eq entity.enabled
      # expect(remote.tags).to eq entity.tags
      subject.delete(entity)
    end

    it 'replaces valid entity' do
      entity = Entity.new name: 'test_entity',
                          enabled: false,
                          tags: { tag: 'value' }
      subject.create_or_replace(entity)
      entity = Entity.new name: entity.name,
                          enabled: true
      subject.create_or_replace(entity)
      remote = subject.get(entity.name)
      expect(remote.name).to eq entity.name
      expect(remote.enabled).to eq entity.enabled
      expect(remote.tags?).to be_empty
      subject.delete(entity)
    end
  end

  context '#update' do
    it 'updates valid entity' do
      entity = Entity.new name: 'test_entity',
                          enabled: false,
                          tags: { 'tag' => 'value' }
      subject.create_or_replace(entity)
      entity_update = { name: entity.name, enabled: true }
      subject.update(entity_update)
      remote = subject.get(entity.name)
      expect(remote.name).to eq entity.name
      expect(remote.enabled).to eq entity_update[:enabled]
      expect(remote.tags).to eq entity.tags
      subject.delete(entity)
    end

    it 'raises error on non-valid' do
      expect { subject.update({ name:'entity404', enabled: true }) }.to raise_exception APIError
    end
  end

  context '#delete' do
    it 'delete existent entity' do
      entity = Entity.new name: 'test_entity',
                          enabled: false
      subject.create_or_replace(entity)
      subject.delete(entity)
      expect { subject.get(entity.name) }.to raise_exception APIError do |error|
        expect(error.status).to eq 404
      end
    end

    it 'raises error if there is no entity' do
      expect { subject.delete('entity404') }.to raise_exception APIError
    end
  end

  context '#property_types' do
    let(:propertiesService) { PropertiesService.new $client }

    it 'returns an array of property types for entity' do
      entity = Entity.new name: 'test_entity',
                          enabled: true
      subject.create_or_replace(entity)
      types = %w[ type1 type2 type3 ]
      props = types.map do |t|
        Property.new entity: entity.name,
                     type: t,
                     tags: {:t => 'v'},
                     key: {:k => 1}
      end
      propertiesService.insert(props)
      expect(subject.property_types(entity)).to contain_exactly(*types)
      propertiesService.delete(props)
      subject.delete(entity)
    end

    it 'returns empty array for entity with no properties' do
      entity = Entity.new name: 'test_entity2',
                          enabled: true
      subject.create_or_replace(entity)
      expect(subject.property_types(entity)).to be_empty
      subject.delete(entity)
    end
  end

  context '#metrics' do
    let(:seriesService) { SeriesService.new $client }
    it 'return collected metrics from ATSD memory cache' do
      entity = Entity.new name: 'test_entity',
                          enabled: true
      subject.create_or_replace(entity)
      metrics = %w[ m1 m2 m3 m4 m5 ]
      seriesService.insert(metrics.map do |m|
        Series.new entity: entity.name,
                   metric: m,
                   data: [ {t: 1000000000, v: 100} ]
      end)
      expect(subject.metrics(entity).map {|m| m.name}).to contain_exactly(*metrics)
      subject.delete(entity)
    end
  end
end