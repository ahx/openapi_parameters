# frozen_string_literal: true

require 'yaml'

RSpec.describe OpenapiParameters::Parameter do
  describe 'when parameter definition has a $ref' do
    it 'raises an error' do
      definition = {
        'in' => 'query',
        'name' => 'id',
        'schema' => {
          '$ref' => '#/components/schemas/Pet'
        }
      }
      expect { described_class.new(definition) }.to raise_error(
        OpenapiParameters::NotSupportedError
      )
    end
  end

  describe '#name' do
    it 'returns the name' do
      definition = { 'in' => 'query', 'name' => 'id' }
      subject = described_class.new(definition)
      expect(subject.name).to eq 'id'
    end
  end

  describe '#convert' do
    it 'converts the value' do
      definition = { 'in' => 'query', 'name' => 'id', 'schema' => { 'type' => 'integer' } }
      subject = described_class.new(definition)
      expect(subject.convert('2')).to eq 2
    end
  end

  describe '#location' do
    it 'returns the "in" value' do
      definition = { 'in' => 'query', 'name' => 'id' }
      subject = described_class.new(definition)
      expect(subject.location).to eq 'query'
    end
  end

  describe '#in (alias)' do
    it 'returns the "in" value' do
      definition = { 'in' => 'query', 'name' => 'id' }
      subject = described_class.new(definition)
      expect(subject.in).to eq 'query'
    end
  end

  describe '#schema' do
    it 'returns the schema' do
      definition = {
        'in' => 'query',
        'name' => 'id',
        'schema' => {
          'type' => 'string'
        }
      }
      subject = described_class.new(definition)
      expect(subject.schema).to eq({ 'type' => 'string' })
    end

    it 'returns the content schema if content is specified' do
      parameter =
        described_class.new(
          'in' => 'query',
          'schema' => {
            'type' => 'string'
          },
          'content' => {
            'application/json' => {
              'schema' => {
                'type' => 'integer'
              }
            }
          }
        )
      expect(parameter.schema).to eq({ 'type' => 'integer' })
    end
  end

  describe '#primitive?' do
    it 'returns true if type not defined' do
      parameter = described_class.new({ 'in' => 'query' })
      expect(parameter.primitive?).to be true
    end

    it 'returns true if type is string' do
      parameter =
        described_class.new(
          { 'in' => 'query', 'schema' => { 'type' => 'string' } }
        )
      expect(parameter.primitive?).to be true
    end

    it 'returns true if type is integer' do
      parameter =
        described_class.new(
          { 'in' => 'query', 'schema' => { 'type' => 'integer' } }
        )
      expect(parameter.primitive?).to be true
    end

    it 'returns true if type is number' do
      parameter =
        described_class.new(
          { 'in' => 'query', 'schema' => { 'type' => 'number' } }
        )
      expect(parameter.primitive?).to be true
    end

    it 'returns false if type is array' do
      parameter =
        described_class.new(
          { 'in' => 'query', 'schema' => { 'type' => 'array' } }
        )
      expect(parameter.primitive?).to be false
    end

    it 'returns false if type is object' do
      parameter =
        described_class.new(
          { 'in' => 'query', 'schema' => { 'type' => 'object' } }
        )
      expect(parameter.primitive?).to be false
    end
  end

  describe '#array?' do
    it 'returns true if type is array' do
      parameter =
        described_class.new(
          { 'in' => 'query', 'schema' => { 'type' => 'array' } }
        )
      expect(parameter.array?).to be true
    end

    it 'returns false if type is not array' do
      parameter =
        described_class.new(
          { 'in' => 'query', 'schema' => { 'type' => 'string' } }
        )
      expect(parameter.array?).to be false
    end
  end

  describe '#object?' do
    it 'returns true if type is object' do
      parameter =
        described_class.new(
          { 'in' => 'query', 'schema' => { 'type' => 'object' } }
        )
      expect(parameter.object?).to be true
    end

    it 'returns true if style is deepObject' do
      parameter =
        described_class.new(
          { 'in' => 'query', 'style' => 'deepObject' }
        )
      expect(parameter.object?).to be true
    end

    it 'is deep_object' do
      parameter = described_class.new(
        { 'in' => 'query', 'style' => 'deepObject' }
      )
      expect(parameter.deep_object?).to be true
    end

    it 'returns true if schema defines properties' do
      parameter =
        described_class.new(
          { 'in' => 'query', 'schema' => { 'properties' => { 'a' => { 'type' => 'string' } } } }
        )
      expect(parameter.object?).to be true
    end

    it 'returns false if type is not object' do
      parameter =
        described_class.new(
          { 'in' => 'query', 'schema' => { 'type' => 'string' } }
        )
      expect(parameter.object?).to be false
    end
  end

  describe '#style' do
    it 'returns the style if defined' do
      parameter = described_class.new('style' => 'form', 'in' => 'query')
      expect(parameter.style).to eq 'form'
    end

    it 'returns "form" for query parameters' do
      parameter = described_class.new('in' => 'query')
      expect(parameter.style).to eq 'form'
    end

    it 'returns "simple" for path parameters' do
      parameter = described_class.new('in' => 'path')
      expect(parameter.style).to eq 'simple'
    end

    it 'returns "simple" for header parameters' do
      parameter = described_class.new('in' => 'header')
      expect(parameter.style).to eq 'simple'
    end

    it 'returns "form" for cookie parameters' do
      parameter = described_class.new('in' => 'cookie')
      expect(parameter.style).to eq 'form'
    end
  end

  describe '#explode?' do
    it 'returns true if explode is true' do
      parameter = described_class.new('explode' => true, 'in' => 'query')
      expect(parameter.explode?).to be true
    end

    it 'returns false if explode is false' do
      parameter = described_class.new('explode' => false, 'in' => 'query')
      expect(parameter.explode?).to be false
    end

    describe 'when explode is not specified' do
      it 'returns true if style is "form"' do
        parameter = described_class.new('style' => 'form', 'in' => 'query')
        expect(parameter.explode?).to be true
      end

      it 'returns false if style is not "form"' do
        parameter =
          described_class.new('style' => 'spaceDelimited', 'in' => 'query')
        expect(parameter.explode?).to be false
      end
    end
  end

  describe '#required?' do
    it 'returns true if required is true' do
      parameter = described_class.new('in' => 'query', 'required' => true)
      expect(parameter.required?).to be true
    end

    it 'returns false if required is false' do
      parameter = described_class.new('in' => 'query', 'required' => false)
      expect(parameter.required?).to be false
    end

    it 'returns true for path paramters' do
      parameter = described_class.new('in' => 'path')
      expect(parameter.required?).to be true
    end

    it 'returns false if required is not specified' do
      %w[query header cookie].each do |location|
        parameter = described_class.new('in' => location)
        expect(parameter.required?).to be false
      end
    end
  end

  describe '#allow_reserved?' do
    it 'returns true if allowReserved is true' do
      parameter = described_class.new('in' => 'query', 'allowReserved' => true)
      expect(parameter.allow_reserved?).to be true
    end

    it 'returns false if allowReserved is false' do
      parameter = described_class.new('in' => 'query', 'allowReserved' => false)
      expect(parameter.allow_reserved?).to be false
    end

    it 'returns false if allowReserved is not specified' do
      parameter = described_class.new('in' => 'query')
      expect(parameter.allow_reserved?).to be false
    end
  end

  describe '#media_type' do
    it 'returns the media type' do
      parameter =
        described_class.new(
          'in' => 'query',
          'content' => {
            'application/json' => {
              'schema' => {
                'type' => 'string'
              }
            }
          }
        )
      expect(parameter.media_type).to eq 'application/json'
    end

    it 'returns nil if "content" is not defined' do
      parameter = described_class.new('in' => 'query')
      expect(parameter.media_type).to be_nil
    end
  end

  describe '#deprecated?' do
    it 'returns true if deprecated is true' do
      parameter = described_class.new('in' => 'query', 'deprecated' => true)
      expect(parameter.deprecated?).to be true
    end

    it 'returns false if deprecated is false' do
      parameter = described_class.new('in' => 'query', 'deprecated' => false)
      expect(parameter.deprecated?).to be false
    end

    it 'returns false if deprecated is not specified' do
      parameter = described_class.new('in' => 'query')
      expect(parameter.deprecated?).to be false
    end
  end
end
