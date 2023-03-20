# frozen_string_literal: true

require_relative '../../lib/openapi_parameters/query'

RSpec.describe OpenapiParameters::Query do
  describe '#unpack' do

    it 'returns a string value if no type is defined' do
      parameter = { 'in' => 'query', 'name' => 'id' }
      value = described_class.new([parameter]).unpack('id=abc')
      expect(value).to eq('id' => 'abc')
    end

    it 'excludes unknown query parameters' do
      parameter = {
        'in' => 'query',
        'name' => 'id',
        'schema' => {
          'type' => 'string',
        },
      }
      value = described_class.new([parameter]).unpack('id=abc&unknown=xyz')
      expect(value).to eq('id' => 'abc')
    end

    describe 'Primitive parameter' do
      it 'returns a string' do
        parameter = {
          'in' => 'query',
          'name' => 'id',
          'schema' => {
            'type' => 'string',
          },
        }
        value = described_class.new([parameter]).unpack('id=abc')
        expect(value).to eq('id' => 'abc')
      end

      it 'does not add key if not set' do
        parameter = {
          'in' => 'query',
          'name' => 'id',
          'schema' => {
            'type' => 'string',
          },
        }
        value = described_class.new([parameter]).unpack('')
        expect(value).to eq({})
      end

      it 'works with pet-id=abc' do
        parameter = {
          'in' => 'query',
          'name' => 'pet-id',
          'schema' => {
            'type' => 'string',
          },
        }
        value = described_class.new([parameter]).unpack('pet-id=abc')
        expect(value).to eq('pet-id' => 'abc')
      end

      it 'works with brackets in name' do
        query_string = 'filter[name]=abc'
        parameter = {
          'in' => 'query',
          'name' => 'filter[name]',
          'schema' => {
            'type' => 'string',
          },
        }
        value = described_class.new([parameter]).unpack(query_string)
        expect(value).to eq('filter[name]' => 'abc')
      end

      it 'works with complex name' do
        query_string = 'x[[]abc]=abc'
        parameter = {
          'in' => 'query',
          'name' => 'x[[]abc]',
          'schema' => {
            'type' => 'string',
          },
        }
        value = described_class.new([parameter]).unpack(query_string)
        expect(value).to eq('x[[]abc]' => 'abc')
      end
    end

    describe 'Array explode true' do
      it 'applies explode true if explode is undefined' do
        query_string = 'name=a&name=b&name=c'
        parameter = {
          'in' => 'query',
          'name' => 'name',
          'schema' => {
            'type' => 'array',
            'items' => {
              'type' => 'string',
            },
          },
        }
        value = described_class.new([parameter]).unpack(query_string)
        expect(value).to eq('name' => %w[a b c])
      end

      it 'returns an array' do
        query_string = 'name=a&name=b&name=c'
        parameter = {
          'in' => 'query',
          'name' => 'name',
          'explode' => true,
          'style' => 'form',
          'schema' => {
            'type' => 'array',
            'items' => {
              'type' => 'string',
            },
          },
        }
        value = described_class.new([parameter]).unpack(query_string)
        expect(value).to eq('name' => %w[a b c])
      end

      it 'works with brackets in name' do
        query_string = 'names[]=a&names[]=b&names[]=c'
        parameter = {
          'in' => 'query',
          'name' => 'names[]',
          'explode' => true,
          'style' => 'form',
          'schema' => {
            'type' => 'array',
            'items' => {
              'type' => 'string',
            },
          },
        }
        value = described_class.new([parameter]).unpack(query_string)
        expect(value).to eq('names[]' => %w[a b c])
      end
    end

    describe 'Array explode false' do
      it 'returns an array' do
        query_string = 'name=a,b,c'
        parameter = {
          'in' => 'query',
          'name' => 'name',
          'explode' => false,
          'style' => 'form',
          'schema' => {
            'type' => 'array',
            'items' => {
              'type' => 'string',
            },
          },
        }
        value = described_class.new([parameter]).unpack(query_string)
        expect(value).to eq('name' => %w[a b c])
      end

      it 'supports style: spaceDelimited' do
        query_string = 'name=a%20b%20c'
        parameter = {
          'in' => 'query',
          'name' => 'name',
          'explode' => false,
          'style' => 'spaceDelimited',
          'schema' => {
            'type' => 'array',
            'items' => {
              'type' => 'string',
            },
          },
        }
        value = described_class.new([parameter]).unpack(query_string)
        expect(value).to eq('name' => %w[a b c])
      end

      it 'supports style: pipeDelimited' do
        query_string = 'name=a%7Cb%7Cc'
        parameter = {
          'in' => 'query',
          'name' => 'name',
          'explode' => false,
          'style' => 'pipeDelimited',
          'schema' => {
            'type' => 'array',
            'items' => {
              'type' => 'string',
            },
          },
        }
        value = described_class.new([parameter]).unpack(query_string)
        expect(value).to eq('name' => %w[a b c])
      end
    end

    describe 'Object style: deepObject' do
      let(:parameter) do
        {
          'in' => 'query',
          'name' => 'color',
          'explode' => true,
          'style' => 'deepObject',
          'schema' => {
            'type' => 'object',
            'properties' => {
              'R' => {
                'type' => 'integer',
              },
              'G' => {
                'type' => 'integer',
              },
              'B' => {
                'type' => 'integer',
              },
            },
          },
        }
      end

      it 'returns an object' do
        query_string = 'color[R]=100&color[G]=200&color[B]=150'
        value = described_class.new([parameter]).unpack(query_string)
        expect(value).to eq(
          'color' => {
            'R' => '100',
            'G' => '200',
            'B' => '150',
          },
        )
      end

      it 'does not add key if not set' do
        value = described_class.new([parameter]).unpack('')
        expect(value).to eq({})
      end
    end

    describe 'Object explode false' do
      it 'supports style: form' do
        query_string = 'color=R,100,G,200,B,150'
        parameter = {
          'in' => 'query',
          'name' => 'color',
          'explode' => false,
          'style' => 'form',
          'schema' => {
            'type' => 'object',
            'properties' => {
              'R' => {
                'type' => 'integer',
              },
              'G' => {
                'type' => 'integer',
              },
              'B' => {
                'type' => 'integer',
              },
            },
          },
        }
        value = described_class.new([parameter]).unpack(query_string)
        expect(value).to eq(
          'color' => {
            'R' => '100',
            'G' => '200',
            'B' => '150',
          },
        )
      end
    end
  end
end
