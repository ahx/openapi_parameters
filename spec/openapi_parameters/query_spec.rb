# frozen_string_literal: true

RSpec.describe OpenapiParameters::Query do
  describe '#unpack' do
    it 'returns a string value if no type is defined' do
      parameter = { 'in' => 'query', 'name' => 'id' }
      value = described_class.new([parameter]).unpack('id=abc')
      expect(value).to eq('id' => 'abc')
    end

    it 'returns an empty string for empty string parameters' do
      parameter = { 'in' => 'query', 'name' => 'id' }
      value = described_class.new([parameter]).unpack('id=&')
      expect(value).to eq('id' => '')
    end

    it 'returns an empty string for empty integer parameters' do
      parameter = { 'in' => 'query', 'name' => 'id', 'schema' => { 'type' => 'integer' } }
      value = described_class.new([parameter]).unpack('id=&')
      expect(value).to eq('id' => '')
    end

    it 'excludes unknown query parameters' do
      parameter = {
        'in' => 'query',
        'name' => 'id',
        'schema' => {
          'type' => 'string'
        }
      }
      value = described_class.new([parameter]).unpack('id=abc&unknown=xyz')
      expect(value).to eq('id' => 'abc')
    end

    it 'returns a converted value by default' do
      parameter = {
        'in' => 'query',
        'name' => 'id',
        'schema' => {
          'type' => 'integer'
        }
      }
      value = described_class.new([parameter]).unpack('id=1')
      expect(value).to eq('id' => 1)
    end

    it 'accepts convert: false' do
      parameter = {
        'in' => 'query',
        'name' => 'id',
        'schema' => {
          'type' => 'integer'
        }
      }
      value = described_class.new([parameter], convert: false).unpack('id=1')
      expect(value).to eq('id' => '1')
    end

    describe 'Primitive parameter' do
      it 'returns a string' do
        parameter = {
          'in' => 'query',
          'name' => 'id',
          'schema' => {
            'type' => 'string'
          }
        }
        value = described_class.new([parameter]).unpack('id=abc')
        expect(value).to eq('id' => 'abc')
      end

      it 'does not add key if not set' do
        parameter = {
          'in' => 'query',
          'name' => 'id',
          'schema' => {
            'type' => 'string'
          }
        }
        value = described_class.new([parameter]).unpack('')
        expect(value).to eq({})
      end

      it 'works with pet-id=abc' do
        parameter = {
          'in' => 'query',
          'name' => 'pet-id',
          'schema' => {
            'type' => 'string'
          }
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
            'type' => 'string'
          }
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
            'type' => 'string'
          }
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
              'type' => 'string'
            }
          }
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
              'type' => 'string'
            }
          }
        }
        value = described_class.new([parameter]).unpack(query_string)
        expect(value).to eq('name' => %w[a b c])
      end

      it 'returns an array with one element' do
        query_string = 'name=a'
        parameter = {
          'in' => 'query',
          'name' => 'name',
          'explode' => true,
          'style' => 'form',
          'schema' => {
            'type' => 'array'
          }
        }
        value = described_class.new([parameter]).unpack(query_string)
        expect(value).to eq('name' => %w[a])
      end

      it 'returns an empty value' do
        query_string = 'name=&'
        parameter = {
          'in' => 'query',
          'name' => 'name',
          'explode' => true,
          'style' => 'form',
          'schema' => {
            'type' => 'array'
          }
        }
        value = described_class.new([parameter]).unpack(query_string)
        expect(value).to eq('name' => '')
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
              'type' => 'string'
            }
          }
        }
        value = described_class.new([parameter]).unpack(query_string)
        expect(value).to eq('names[]' => %w[a b c])
      end

      it 'works with filter[id]' do
        query_string = 'filter[id]=a&filter[id]=b&filter[id]=c'
        parameter = {
          'in' => 'query',
          'name' => 'filter[id]',
          'explode' => true,
          'style' => 'form',
          'schema' => {
            'type' => 'array',
            'items' => {
              'type' => 'string'
            }
          }
        }
        value = described_class.new([parameter]).unpack(query_string)
        expect(value).to eq('filter[id]' => %w[a b c])
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
              'type' => 'string'
            }
          }
        }
        value = described_class.new([parameter]).unpack(query_string)
        expect(value).to eq('name' => %w[a b c])
      end

      it 'returns an array with one element' do
        query_string = 'name=a'
        parameter = {
          'in' => 'query',
          'name' => 'name',
          'explode' => false,
          'style' => 'form',
          'schema' => {
            'type' => 'array'
          }
        }
        value = described_class.new([parameter]).unpack(query_string)
        expect(value).to eq('name' => %w[a])
      end

      it 'returns an empty value' do
        query_string = 'name=&'
        parameter = {
          'in' => 'query',
          'name' => 'name',
          'explode' => false,
          'style' => 'form',
          'schema' => {
            'type' => 'array'
          }
        }
        value = described_class.new([parameter]).unpack(query_string)
        expect(value).to eq('name' => '')
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
              'type' => 'string'
            }
          }
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
              'type' => 'string'
            }
          }
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
                'type' => 'integer'
              },
              'G' => {
                'type' => 'integer'
              },
              'B' => {
                'type' => 'integer'
              },
              'nested' => {
                'type' => 'object',
                'properties' => {
                  'a' => {
                    'type' => 'integer'
                  }
                }
              }
            }
          }
        }
      end

      it 'returns an object' do
        query_string = 'color[R]=100&color[G]=200&color[B]=150'
        value = described_class.new([parameter]).unpack(query_string)
        expect(value).to eq(
          'color' => {
            'R' => 100,
            'G' => 200,
            'B' => 150
          }
        )
      end

      it 'returns the original value if unpacking fails' do
        query_string = 'color=RGB'
        value = described_class.new([parameter]).unpack(query_string)
        expect(value).to eq(
          'color' => 'RGB'
        )
      end

      it 'does not add key if not set' do
        value = described_class.new([parameter]).unpack('')
        expect(value).to eq({})
      end

      it 'supports nested objects' do
        query_string = 'color[R]=100&color[nested][a]=42'
        value = described_class.new([parameter]).unpack(query_string)
        expect(value).to eq(
          'color' => {
            'R' => 100,
            'nested' => {
              'a' => 42
            }
          }
        )
      end

      context 'without object type specified' do
        let(:parameter) do
          {
            'in' => 'query',
            'name' => 'color',
            'explode' => true,
            'style' => 'deepObject',
            'schema' => {
              'properties' => {
                'R' => {
                  'type' => 'integer'
                }
              }
            }
          }
        end

        it 'still returns an object' do
          query_string = 'color[R]=100'
          value = described_class.new([parameter]).unpack(query_string)
          expect(value).to eq(
            'color' => {
              'R' => 100
            }
          )
        end
      end
    end

    describe 'Object style: deepObject with nested array value is not supported' do
      # All of these are not supported. See also https://github.com/OAI/OpenAPI-Specification/issues/1706

      let(:parameter) do
        {
          'in' => 'query',
          'name' => 'color',
          'explode' => true,
          'style' => 'deepObject',
          'schema' => {
            'type' => 'object',
            'properties' => {
              'values' => {
                'type' => 'array',
                'items' => {
                  'type' => 'integer'
                }
              }
            }
          }
        }
      end

      it 'does not convert single value' do
        query_string = 'color[values]=100'
        value = described_class.new([parameter]).unpack(query_string)
        expect(value).to eq(
          'color' => {
            'values' => '100'
          }
        )
      end

      it 'does not convert exploded multiple values' do
        query_string = 'color[values]=100&color[values]=255'
        value = described_class.new([parameter]).unpack(query_string)
        expect(value).to eq(
          'color' => {
            'values' => '255'
          }
        )
      end

      it 'does not convert comma-separated values' do
        query_string = 'color[values]=100,255'
        value = described_class.new([parameter]).unpack(query_string)
        expect(value).to eq(
          'color' => {
            'values' => '100,255'
          }
        )
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
                'type' => 'integer'
              },
              'G' => {
                'type' => 'integer'
              },
              'B' => {
                'type' => 'integer'
              }
            }
          }
        }
        value = described_class.new([parameter]).unpack(query_string)
        expect(value).to eq(
          'color' => {
            'R' => 100,
            'G' => 200,
            'B' => 150
          }
        )
      end
    end
  end
end
