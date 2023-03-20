# frozen_string_literal: true

require_relative '../../lib/openapi_parameters/header'

RSpec.describe OpenapiParameters::Header do
  describe '#unpack_env' do
    it 'returns the header value' do
      env = { 'HTTP_X_SOME' => 'abc' }
      parameter = { 'in' => 'header', 'name' => 'X-Some' }
      value = described_class.new([parameter]).unpack_env(env)
      expect(value).to eq('X-Some' => 'abc')
    end
  end

  describe '#unpack' do
    it 'returns a string value if no type is defined' do
      parameter = { 'in' => 'header', 'name' => 'X-Some' }
      value = described_class.new([parameter]).unpack('X-Some' => 'abc')
      expect(value).to eq('X-Some' => 'abc')
    end

    it 'excludes unknown headers' do
      parameter = {
        'in' => 'header',
        'name' => 'X-Some',
        'schema' => {
          'type' => 'string'
        }
      }
      value =
        described_class.new([parameter]).unpack(
          { 'X-Some' => 'abc', 'X-Unknown' => 'xyz' }
        )
      expect(value).to eq('X-Some' => 'abc')
    end

    describe 'Primitive parameter' do
      it 'returns a string' do
        parameter = {
          'in' => 'header',
          'name' => 'X-Some',
          'schema' => {
            'type' => 'string'
          }
        }
        headers = { 'X-Some' => '12' }
        value = described_class.new([parameter]).unpack(headers)
        expect(value).to eq('X-Some' => '12')
      end

      it 'does not add key if not set' do
        parameter = {
          'in' => 'header',
          'name' => 'X-Some',
          'schema' => {
            'type' => 'integer'
          }
        }
        value = described_class.new([parameter]).unpack({})
        expect(value).to eq({})
      end

      it 'works with special characters in names' do
        headers = { '[]some[things]%' => '12' }
        parameter = {
          'in' => 'header',
          'name' => '[]some[things]%',
          'schema' => {
            'type' => 'integer'
          }
        }
        value = described_class.new([parameter]).unpack(headers)
        expect(value).to eq('[]some[things]%' => '12')
      end
    end

    describe 'Array explode true' do
      it 'returns an array' do
        headers = { 'X-Some' => '1,2' }
        parameter = {
          'in' => 'header',
          'name' => 'X-Some',
          'explode' => true,
          'schema' => {
            'type' => 'array'
          }
        }
        value = described_class.new([parameter]).unpack(headers)
        expect(value).to eq('X-Some' => %w[1 2])
      end

      it 'excludes key if not set' do
        parameter = {
          'in' => 'header',
          'name' => 'X-Some',
          'explode' => true,
          'schema' => {
            'type' => 'array'
          }
        }
        value = described_class.new([parameter]).unpack({})
        expect(value).to eq({})
      end
    end

    describe 'Array explode false' do
      it 'returns an array' do
        headers = { 'X-Some' => '1,2' }
        parameter = {
          'in' => 'header',
          'name' => 'X-Some',
          'explode' => false,
          'schema' => {
            'type' => 'array'
          }
        }
        value = described_class.new([parameter]).unpack(headers)
        expect(value).to eq('X-Some' => %w[1 2])
      end
    end

    describe 'Object explode true' do
      it 'applies the "simple" style by default' do
        headers = { 'X-Some' => 'R=100,G=200,B=150' }
        parameter = {
          'in' => 'header',
          'name' => 'X-Some',
          'explode' => true,
          'schema' => {
            'type' => 'object'
          }
        }
        value = described_class.new([parameter]).unpack(headers)
        expect(value).to eq(
          'X-Some' => {
            'R' => '100',
            'G' => '200',
            'B' => '150'
          }
        )
      end

      it 'excludes if not set' do
        parameter = {
          'in' => 'header',
          'name' => 'X-Some',
          'explode' => true,
          'schema' => {
            'type' => 'object'
          }
        }
        value = described_class.new([parameter]).unpack({})
        expect(value).to eq({})
      end

      it 'accepts the "simple" style' do
        headers = { 'X-Some' => 'R=100,G=200,B=150' }
        parameter = {
          'in' => 'header',
          'name' => 'X-Some',
          'explode' => true,
          'style' => 'simple',
          'schema' => {
            'type' => 'object'
          }
        }
        value = described_class.new([parameter]).unpack(headers)
        expect(value).to eq(
          'X-Some' => {
            'R' => '100',
            'G' => '200',
            'B' => '150'
          }
        )
      end

      it 'returns the unpacked value if value is malformated' do
        headers = { 'X-Some' => 'R=100,G200,B=150' }
        parameter = {
          'in' => 'header',
          'name' => 'X-Some',
          'explode' => true,
          'schema' => {
            'type' => 'object'
          }
        }
        value = described_class.new([parameter]).unpack(headers)
        expect(value).to eq('X-Some' => 'R=100,G200,B=150')
      end
    end

    describe 'Object explode false' do
      it 'applies the "simple" style and explode false by default' do
        headers = { 'X-Some' => 'R,100,G,200,B,150' }
        parameter = {
          'in' => 'header',
          'name' => 'X-Some',
          'schema' => {
            'type' => 'object'
          }
        }
        value = described_class.new([parameter]).unpack(headers)
        expect(value).to eq(
          'X-Some' => {
            'R' => '100',
            'G' => '200',
            'B' => '150'
          }
        )
      end

      it 'returns the unpacked value if value is malformated' do
        headers = { 'X-Some' => 'R,100,G200,B,150' }
        parameter = {
          'in' => 'header',
          'name' => 'X-Some',
          'schema' => {
            'type' => 'object'
          }
        }
        value = described_class.new([parameter]).unpack(headers)
        expect(value).to eq('X-Some' => 'R,100,G200,B,150')
      end

      it 'accepts the "simple" style' do
        headers = { 'X-Some' => 'R,100,G,200,B,150' }
        parameter = {
          'in' => 'header',
          'name' => 'X-Some',
          'explode' => false,
          'style' => 'simple',
          'schema' => {
            'type' => 'object'
          }
        }
        value = described_class.new([parameter]).unpack(headers)
        expect(value).to eq(
          'X-Some' => {
            'R' => '100',
            'G' => '200',
            'B' => '150'
          }
        )
      end
    end
  end
end
