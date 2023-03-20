# frozen_string_literal: true

require_relative '../../lib/openapi_parameters/converter'

RSpec.describe OpenapiParameters::Converter do
  describe 'No schema defined' do
    it 'does not convert the value' do
      expect(described_class.call('123', nil)).to eq('123')
    end
  end

  describe 'No schema type defined' do
    it 'does not convert the value' do
      expect(described_class.call('1', {})).to eq('1')
    end
  end

  it 'keeps unknown values' do
    expect(described_class.call('123', {})).to eq('123')
  end

  it 'keeps string values' do
    expect(described_class.call('123', 'type' => 'string')).to eq('123')
  end

  it 'converts a string to an integer' do
    expect(described_class.call('123', 'type' => 'integer')).to eq(123)
  end

  it 'returns nil' do
    expect(described_class.call(nil, 'type' => 'integer')).to be_nil
  end

  it 'keeps an integer an integer' do
    expect(described_class.call(123, 'type' => 'integer')).to eq(123)
  end

  it 'converts a string to a float' do
    expect(described_class.call('12.3', 'type' => 'number')).to eq(12.3)
  end

  it 'converts a string to true' do
    expect(described_class.call('true', 'type' => 'boolean')).to be(true)
  end

  it 'converts a string to false' do
    expect(described_class.call('false', 'type' => 'boolean')).to be(false)
  end

  it 'ignores format' do
    expect(
      described_class.call(
        '2020-09-15',
        'type' => 'string',
        'format' => 'date',
      ),
    ).to eq('2020-09-15')
  end

  it 'converts values of an object' do
    schema = {
      'type' => 'object',
      'properties' => {
        'id' => {
          'type' => 'integer',
        },
      },
    }
    input = { 'id' => '123' }
    expect(described_class.call(input, schema)).to eq({ 'id' => 123 })
  end

  it 'converts values of a nested object' do
    schema = {
      'type' => 'object',
      'properties' => {
        'data' => {
          'type' => 'object',
          'properties' => {
            'id' => {
              'type' => 'integer',
            },
          },
        },
      },
    }
    input = { 'data' => { 'id' => '123' } }
    expect(described_class.call(input, schema)).to eq(
      { 'data' => { 'id' => 123 } },
    )
  end

  it 'converts array items' do
    schema = { 'type' => 'array', 'items' => { 'type' => 'integer' } }
    input = %w[1 2 3]
    expect(described_class.call(input, schema)).to eq([1, 2, 3])
  end

  it 'converts array items with prefixItems defined' do
    schema = {
      'type' => 'array',
      'prefixItems' => [{ 'type' => 'string' }, { 'type' => 'integer' }],
    }
    input = %w[1 2]
    expect(described_class.call(input, schema)).to eq(['1', 2])
  end

  it 'converts array items with prefixItems but ignores additional items' do
    schema = { 'type' => 'array', 'prefixItems' => [{ 'type' => 'integer' }] }
    input = %w[1 2 3]
    expect(described_class.call(input, schema)).to eq([1, '2', '3'])
  end

  it 'converts array items with prefixItems and items defined as defined in JSON Schema 2020' do
    schema = {
      'type' => 'array',
      'prefixItems' => [
        { 'type' => 'integer' },
        { 'type' => 'string' },
        { 'type' => 'integer' },
      ],
      'items' => {
        'type' => 'integer',
      },
    }
    input = %w[1 a 3 4 5]
    expect(described_class.call(input, schema)).to eq([1, 'a', 3, 4, 5])
  end

  it 'converts items in nested arrays' do
    schema = {
      'type' => 'array',
      'items' => {
        'type' => 'array',
        'items' => {
          'type' => 'integer',
        },
      },
    }
    input = [%w[1 2], %w[3 4]]
    expect(described_class.call(input, schema)).to eq([[1, 2], [3, 4]])
  end

  it 'converts nested objects and arrays' do
    schema = {
      'type' => 'object',
      'properties' => {
        'data' => {
          'type' => 'array',
          'items' => {
            'type' => 'object',
            'properties' => {
              'id' => {
                'type' => 'integer',
              },
              'clientIds' => {
                'type' => 'array',
                'items' => {
                  'type' => 'integer',
                },
              },
            },
          },
        },
      },
    }
    input = { 'data' => [{ 'id' => '1', 'clientIds' => %w[1 2] }] }
    expect(described_class.call(input, schema)).to eq(
      { 'data' => [{ 'id' => 1, 'clientIds' => [1, 2] }] },
    )
  end

  it 'raises an error when schema has a $ref deep inside' do
    schema = {
      'type' => 'object',
      'properties' => {
        'meta' => {
          '$ref' => '#/components/schemas/Meta',
        },
      },
    }
    input = { 'meta' => { 'id' => '1' } }
    expect { described_class.call(input, schema) }.to raise_error(
      OpenapiParameters::NotSupportedError,
    )
  end
end
