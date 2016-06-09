require 'helpers/shared_client'

include ATSD

RSpec.describe MetricsService do
  include_context 'client'
  subject { MetricsService.new $client }

  context '#list' do
    it 'return array of Metric' do
      metrics = subject.list name:'meminfo.*'
      metrics.each do |g|
        expect(g).to be_a Metric
      end
    end
  end

  context '#get' do
    it 'return Metric' do
      name = 'meminfo.cached'
      metric = subject.get(name)
      expect(metric).to be_a Metric
      expect(metric.name).to eq name
    end

    it 'raise error if nothing found' do
      expect { subject.get('not_found_metric') }.to raise_error
    end
  end

  context '#create_or_replace' do
    it 'creates new metric if it does not exist' do
      local = Metric.new name: 'my_test_metric'
      subject.create_or_replace(local)
      metric = subject.get(local)
      expect(metric).to be_a Metric
      expect(metric.name).to eq local.name
      subject.delete(metric)
    end

    it 'replaces existing metric' do
      local = Metric.new name: 'another_one',
                         label: 'Label 1',
                         data_type: 'SHORT'
      subject.create_or_replace(local)
      metric = subject.get(local)
      expect(metric).to be_a Metric
      expect(metric.name).to eq local.name
      expect(metric.label).to eq local.label

      local2 = Metric.new name: 'another_one',
                          label: 'Label 2'
      subject.create_or_replace(local2)
      metric2 = subject.get(local2)
      expect(metric2.label).to eq local2.label
      expect(metric2.dataType).not_to eq local.data_type
      subject.delete(metric2)
    end

    it 'raise error on empty input' do
      expect { subject.create_or_replace({}) }.to raise_error
    end
  end

  context '#update' do
    it 'raise error if no metric found' do
      expect { subject.update(name: 'not_found_metric') }.to raise_error
    end

    it 'updates existing metric' do
      local = Metric.new name: 'another_one',
                         label: 'Label 1',
                         data_type: 'SHORT'
      subject.create_or_replace(local)
      metric = subject.get(local)
      expect(metric).to be_a Metric
      expect(metric.name).to eq local.name
      expect(metric.label).to eq local.label

      local2 = local.dup
      local2[:label] = 'Label 2'
      subject.update(local2)

      metric2 = subject.get(local2)
      expect(metric2.label).to eq local2.label
      expect(metric2.dataType).to eq local.data_type

      subject.delete(metric2)
    end
  end

  context '#delete' do
    it 'raise error if no metric found' do
      expect { subject.delete(name: 'not_found_metric') }.to raise_error
    end

    it 'deletes existing metric' do
      name = 'ttt'
      subject.create_or_replace(name: name)
      subject.delete(name)
      expect { subject.get(name) }.to raise_error
    end
  end

  context '#entity_and_tags' do
    it 'returns array of entities' do
      result = subject.entity_and_tags('meminfo.active')
      expect(result).to be_a Array
      result.each do |r|
        expect(r).to be_a Entity
      end
    end
  end
end