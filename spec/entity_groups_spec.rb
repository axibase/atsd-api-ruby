require 'helpers/shared_client'

include ATSD

RSpec.describe EntityGroupsService do
  include_context 'client'
  subject { EntityGroupsService.new $client }

  context '#list' do
    it 'return array of EntityGroup' do
      to_create = %w[eg1 eg2 eg3].each { |g| subject.create_or_replace(name:g) }

      groups = subject.list
      expect(groups.count).to eq(to_create.count)
      groups.each do |g|
        expect(g).to be_a EntityGroup
      end

      groups.each { |g| subject.delete(g) }
    end
  end

  context '#get' do
    it 'return EntityGroup' do
      name = 'eg4'
      subject.create_or_replace(name)
      group = subject.get(name)
      expect(group).to be_a EntityGroup
      expect(group.name).to eq name
      subject.delete(name)
    end

    it 'raise error if nothing found' do
      expect { subject.get('not_found_group') }.to raise_error
    end
  end

  context '#create_or_replace' do
    it 'creates new group if it does not exist' do
      local = EntityGroup.new name: 'yyy'
      subject.create_or_replace(local)
      group = subject.get(local)
      expect(group).to be_a EntityGroup
      expect(group.name).to eq local.name
      subject.delete(group)
    end

    it 'replaces existing group' do
      local = EntityGroup.new name: 'xxx',
                              tags: { 'tag1' => 'val1' }
      subject.create_or_replace(local)
      group = subject.get(local)
      expect(group).to be_a EntityGroup
      expect(group).to eq local
      local2 = EntityGroup.new name: 'xxx'
      subject.create_or_replace(local2)
      group2 = subject.get(local2)
      expect(group2.tags).to be_empty
      subject.delete(group2)
    end

    it 'raise error on empty input' do
      expect { subject.create_or_replace({}) }.to raise_error
    end
  end

  context '#update' do
    it 'raise error if no group found' do
      expect { subject.update(name: 'not_found_group') }.to raise_error
    end

    it 'updates existing group' do
      local = EntityGroup.new name: 'zzz',
                              tags: { 'tag1' => 'val1' }
      subject.create_or_replace(local)
      local.tags = { 'tag1' => 'val2' }
      subject.update(local)
      expect(subject.get(local).tags['tag1']).to eq 'val2'
      subject.delete(local)
    end
  end

  context '#delete' do
    it 'raise error if no group found' do
      expect { subject.delete(name: 'not_found_group') }.to raise_error
    end

    it 'deletes existing group' do
      name = 'ttt'
      subject.create_or_replace(name: name)
      subject.delete(name)
      expect { subject.get(name) }.to raise_error
    end
  end

  context '#entities' do
    it 'raise error if group not found' do
      expect { subject.entities(name: 'not_found_group') }.to raise_error
    end

    it 'return array of Entity for group' do
      name = 'qqq'
      entities = %w[e1 e2 e3 e4]
      subject.create_or_replace(name: name)
      subject.add_entities(name, entities.map {|e| {name: e}})
      remote = subject.entities(name)
      expect(remote.count).to eq entities.count
      remote.each do |e|
        expect(e).to be_a Entity
      end
      subject.delete(name)
    end
  end

  context '#add_entities' do
    it 'raise error if group not found' do
      expect { subject.add_entities({name: 'not_found_group'}, []) }.to raise_error
    end

    it 'add entities to group' do
      name = 'hhh'
      entities = %w[e4 e5 e6]
      subject.create_or_replace(name: name)
      subject.add_entities(name, entities.map {|e| {name: e}})
      remote = subject.entities(name)
      expect(remote.map(&:name)).to contain_exactly(*entities)
      subject.delete(name)
    end
  end

  context '#replace_entities' do
    it 'replaces entities for group' do
      name = 'hhh'
      entities = %w[r1 r2]
      entities2 = %w[r3 r4]
      subject.create_or_replace(name: name)
      subject.add_entities(name, entities.map {|e| {name: e}})
      subject.replace_entities(name, entities2.map {|e| {name: e}})
      remote = subject.entities(name)
      expect(remote.map(&:name)).to contain_exactly(*entities2)
      subject.delete(name)
    end
  end

  context '#delete_entities' do
    it 'deletes specified entities' do
      name = 'uuu'
      entities = %w[e4 e6]
      subject.create_or_replace(name: name)
      subject.add_entities(name, entities.map {|e| {name: e}})
      subject.delete_entities(name, entities)
      remote = subject.entities(name)
      expect(remote.count).to eq 0
      subject.delete(name)
    end

    it 'leaves unspecified entities untouched' do
      name = 'iii'
      entities = %w[e4 e6]
      subject.create_or_replace(name: name)
      subject.add_entities(name, entities.map {|e| {name: e}})
      subject.delete_entities(name, entities[0])
      remote = subject.entities(name)
      expect(remote.count).to eq 1
      subject.delete(name)
    end
  end

  context '#delete_all_entities' do
    it 'deletes all entities of group' do
      name = 'uuu'
      entities = %w[e9 e8]
      subject.create_or_replace(name: name)
      subject.add_entities(name, entities.map {|e| {name: e}})
      subject.delete_all_entities(name)
      remote = subject.entities(name)
      expect(remote.count).to eq 0
      subject.delete(name)
    end
  end
end