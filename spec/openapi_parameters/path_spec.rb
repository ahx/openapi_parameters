# frozen_string_literal: true

require_relative '../../lib/openapi_parameters/path'

RSpec.describe OpenapiParameters::Path do
  describe '#unpack' do
    let(:path) { '/pets/{id}' }

    describe 'Primitive parameter' do
      it 'returns the value' do
        path = '/pets/{id}'
        parameter = {
          'in' => 'path',
          'name' => 'id',
          'schema' => {
            'type' => 'integer'
          }
        }
        params = described_class.new([parameter], path).unpack('/pets/12')
        expect(params).to eq('id' => '12')
      end

      it 'returns multiple values' do
        parameters = [
          { 'in' => 'path', 'name' => 'id', 'schema' => { 'type' => 'integer' } },
          {
            'in' => 'path',
            'name' => 'year',
            'schema' => {
              'type' => 'integer'
            }
          }
        ]
        params =
          described_class.new(parameters, '/pets/{id}/schedule/{year}').unpack(
            '/pets/12/schedule/2022'
          )
        expect(params).to eq('id' => '12', 'year' => '2022')
      end
    end

    describe 'Array explode true' do
      it 'returns an array' do
        parameter = {
          'in' => 'path',
          'name' => 'id',
          'explode' => true,
          'schema' => {
            'type' => 'array'
          }
        }
        value = described_class.new([parameter], '/pets/{id}').unpack('/pets/1,2')
        expect(value).to eq('id' => %w[1 2])
      end

      it 'excludes key if parameter is not set' do
        parameter = {
          'in' => 'path',
          'name' => 'id',
          'explode' => true,
          'schema' => {
            'type' => 'array'
          }
        }
        value = described_class.new([parameter], '/pets/{id}').unpack('/pets')
        expect(value).to eq({})
      end

      it 'supports the simple style' do
        parameter = {
          'in' => 'path',
          'name' => 'id',
          'style' => 'simple',
          'explode' => true,
          'schema' => {
            'type' => 'array'
          }
        }
        value = described_class.new([parameter], '/pets/{id}').unpack('/pets/1,2')
        expect(value).to eq('id' => %w[1 2])
      end

      it 'supports the label style' do
        parameter = {
          'in' => 'path',
          'name' => 'color',
          'explode' => true,
          'style' => 'label',
          'schema' => {
            'type' => 'array'
          }
        }
        value =
          described_class.new([parameter], '/pets/{color}').unpack(
            '/pets/.blue.black.brown'
          )
        expect(value).to eq('color' => %w[blue black brown])
      end

      it 'supports the matrix style' do
        parameter = {
          'in' => 'path',
          'name' => 'color',
          'explode' => true,
          'style' => 'matrix',
          'schema' => {
            'type' => 'array'
          }
        }
        value =
          described_class.new([parameter], '/pets/{color}').unpack(
            '/pets/;color=blue;color=black;color=brown'
          )
        expect(value).to eq('color' => %w[blue black brown])
      end
    end

    describe 'Array explode false' do
      it 'returns an array' do
        parameter = {
          'in' => 'path',
          'name' => 'id',
          'explode' => false,
          'schema' => {
            'type' => 'array'
          }
        }
        value = described_class.new([parameter], '/pets/{id}').unpack('/pets/1,2')
        expect(value).to eq('id' => %w[1 2])
      end

      it 'supportes the simple style' do
        parameter = {
          'in' => 'path',
          'name' => 'id',
          'style' => 'simple',
          'explode' => false,
          'schema' => {
            'type' => 'array'
          }
        }
        value = described_class.new([parameter], '/pets/{id}').unpack('/pets/1,2')
        expect(value).to eq('id' => %w[1 2])
      end

      it 'supports the label style' do
        parameter = {
          'in' => 'path',
          'name' => 'id',
          'explode' => true,
          'style' => 'label',
          'schema' => {
            'type' => 'array'
          }
        }
        value =
          described_class.new([parameter], '/pets/{id}').unpack('/pets/.1.2')
        expect(value).to eq('id' => %w[1 2])
      end

      it 'supports the matrix style' do
        parameter = {
          'in' => 'path',
          'name' => 'color',
          'explode' => false,
          'style' => 'matrix',
          'schema' => {
            'type' => 'array'
          }
        }
        value =
          described_class.new([parameter], '/pets/{color}').unpack(
            '/pets/;color=blue,black,brown'
          )
        expect(value).to eq('color' => %w[blue black brown])
      end
    end

    describe 'Object explode true' do
      it 'applies the "simple" style by default' do
        parameter = {
          'in' => 'path',
          'name' => 'color',
          'explode' => true,
          'schema' => {
            'type' => 'object'
          }
        }
        value =
          described_class.new([parameter], '/pets/{color}').unpack(
            '/pets/R=100,G=200,B=150'
          )
        expect(value).to eq(
          'color' => {
            'R' => '100',
            'G' => '200',
            'B' => '150'
          }
        )
      end

      it 'excludes key if not set' do
        parameter = {
          'in' => 'path',
          'name' => 'id',
          'explode' => true,
          'schema' => {
            'type' => 'object'
          }
        }
        value = described_class.new([parameter], '/pets/{id}').unpack('/pets')
        expect(value).to eq({})
      end

      it 'accepts the "simple" style' do
        parameter = {
          'in' => 'path',
          'name' => 'color',
          'explode' => true,
          'style' => 'simple',
          'schema' => {
            'type' => 'object'
          }
        }
        value =
          described_class.new([parameter], '/pets/{color}').unpack(
            '/pets/R=100,G=200,B=150'
          )
        expect(value).to eq(
          'color' => {
            'R' => '100',
            'G' => '200',
            'B' => '150'
          }
        )
      end

      it 'returns the unpacked value if value is malformated' do
        parameter = {
          'in' => 'path',
          'name' => 'color',
          'explode' => true,
          'style' => 'simple',
          'schema' => {
            'type' => 'object'
          }
        }
        value =
          described_class.new([parameter], '/pets/{color}').unpack(
            '/pets/R=100,G200,B=150'
          )
        expect(value).to eq(
          'color' => {
            'B' => '150',
            'G200' => nil,
            'R' => '100'
          }
        )
      end
    end

    describe 'Object explode false' do
      it 'applies the "simple" style and explode false by default' do
        parameter = {
          'in' => 'path',
          'name' => 'color',
          'schema' => {
            'type' => 'object'
          }
        }
        value =
          described_class.new([parameter], '/pets/{color}').unpack(
            '/pets/R,100,G,200,B,150'
          )
        expect(value).to eq(
          'color' => {
            'R' => '100',
            'G' => '200',
            'B' => '150'
          }
        )
      end

      it 'returns the unpacked value if value is malformated' do
        parameter = {
          'in' => 'path',
          'name' => 'color',
          'style' => 'simple',
          'schema' => {
            'type' => 'object'
          }
        }
        value =
          described_class.new([parameter], '/pets/{color}').unpack(
            '/pets/R,100,G200,B,150'
          )
        expect(value).to eq('color' => %w[R 100 G200 B 150])
      end

      it 'accepts "simple" style' do
        parameter = {
          'in' => 'path',
          'name' => 'color',
          'explode' => false,
          'style' => 'simple',
          'schema' => {
            'type' => 'object'
          }
        }
        value =
          described_class.new([parameter], '/pets/{color}').unpack(
            '/pets/R,100,G,200,B,150'
          )
        expect(value).to eq(
          'color' => {
            'R' => '100',
            'G' => '200',
            'B' => '150'
          }
        )
      end

      it 'accepts "matrix" style' do
        parameter = {
          'in' => 'path',
          'name' => 'color',
          'explode' => false,
          'style' => 'matrix',
          'schema' => {
            'type' => 'object'
          }
        }
        value =
          described_class.new([parameter], '/pets/{color}').unpack(
            '/pets/;color=R,100,G,200,B,150'
          )
        expect(value).to eq(
          'color' => {
            'R' => '100',
            'G' => '200',
            'B' => '150'
          }
        )
      end

      it 'accepts "label" style' do
        parameter = {
          'in' => 'path',
          'name' => 'color',
          'explode' => false,
          'style' => 'label',
          'schema' => {
            'type' => 'object'
          }
        }
        value =
          described_class.new([parameter], '/pets/{color}').unpack(
            '/pets/.R,100,G,200,B,150'
          )
        expect(value).to eq(
          'color' => {
            'R' => '100',
            'G' => '200',
            'B' => '150'
          }
        )
      end
    end
  end
end
