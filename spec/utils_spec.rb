require 'rspec'
require 'atsd/utils'

include ATSD

RSpec.describe Utils do
  describe '.ensure_array' do
    it 'converts nil to empty array' do
      expect(Utils.ensure_array(nil)).to eq([])
    end

    it 'leaves array untouched' do
      array = [1, 2, 3]
      expect(Utils.ensure_array(array)).to eq(array)
    end

    it 'wraps object in array' do
      [1, true, 'str'].each do |obj|
        expect(Utils.ensure_array(obj)).to eq([obj])
      end
    end
  end

  describe Utils::CamelizeKeys do
    describe '.camelize_keys' do
      it 'converts snake keys to CamelCase' do
        hash = { :snake_key1 => 1, :snake_key2 => 2 }
        hash_camel = { :snakeKey1 => 1, :snakeKey2 => 2 }
        expect(Utils::CamelizeKeys.camelize_keys(hash)).to eq(hash_camel)
      end

      it 'leaves CamelCase keys unchanged' do
        hash_camel = { :snakeKey1 => 1, :snakeKey2 => 2 }
        expect(Utils::CamelizeKeys.camelize_keys(hash_camel)).to eq(hash_camel)
      end
    end
  end

  before(:context) do
    class MyHash < Hash
      include Utils::UnderscoreKeys
    end
  end

  describe Utils::UnderscoreKeys do
    it 'set camelCase keys as snake keys' do
      hash = MyHash.new
      hash[:SomeKey] = 1
      hash[:anotherKey] = 2
      hash[:snake_key] = 3
      expect(hash[:some_key]).to eq(1)
      expect(hash[:another_key]).to eq(2)
      expect(hash[:snake_key]).to eq(3)
    end
  end
end
