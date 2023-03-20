# frozen_string_literal: true

require_relative '../../lib/openapi_parameters/cookie'

RSpec.describe OpenapiParameters::Cookie do
  describe '#unpack' do
    it 'returns the cookie value' do
      cookies = 'Some=abc;'
      parameter = { 'in' => 'cookie', 'name' => 'Some' }
      value = described_class.new([parameter]).unpack(cookies)
      expect(value).to eq('Some' => 'abc')
    end

    describe 'No schema type defined' do
      it 'returns the cookie value' do
        cookies = 'Some=abc;'
        parameter = { 'in' => 'cookie', 'name' => 'Some', 'schema' => {} }
        value = described_class.new([parameter]).unpack(cookies)
        expect(value).to eq('Some' => 'abc')
      end
    end

    it 'excludes unknown cookies' do
      cookies = 'Other=cde; Some=abc;'
      parameter = { 'in' => 'cookie', 'name' => 'Some' }
      value = described_class.new([parameter]).unpack(cookies)
      expect(value).to eq('Some' => 'abc')
    end

    describe 'Primitive parameter' do
      it 'returns the cookie value' do
        cookies = 'Some=12;'
        parameter = {
          'in' => 'cookie',
          'name' => 'Some',
          'schema' => {
            'type' => 'integer'
          }
        }
        value = described_class.new([parameter]).unpack(cookies)
        expect(value).to eq('Some' => '12')
      end

      it 'excludes key if parameter not set' do
        cookies = ''
        parameter = {
          'in' => 'cookie',
          'name' => 'Some',
          'schema' => {
            'type' => 'integer'
          }
        }
        value = described_class.new([parameter]).unpack(cookies)
        expect(value).to eq({})
      end

      it 'works with special characters in names' do
        cookies = '[]some[things]%=12;'
        parameter = {
          'in' => 'cookie',
          'name' => '[]some[things]%',
          'schema' => {
            'type' => 'integer'
          }
        }
        value = described_class.new([parameter]).unpack(cookies)
        expect(value).to eq('[]some[things]%' => '12')
      end
    end

    describe 'Array explode true' do
      # NOTE: Nobody seems to understand how explode: true should work for arrays in cookie parameters.
      # So this library just ignores the explode flag for arrays.
      it 'returns an array' do
        cookies = 'Some=1,2;'
        parameter = {
          'in' => 'cookie',
          'name' => 'Some',
          'explode' => true,
          'schema' => {
            'type' => 'array'
          }
        }
        value = described_class.new([parameter]).unpack(cookies)
        expect(value).to eq('Some' => %w[1 2])
      end
    end

    describe 'Array explode false' do
      it 'returns an array' do
        cookies = 'Some=1,2;'
        parameter = {
          'in' => 'cookie',
          'name' => 'Some',
          'explode' => false,
          'schema' => {
            'type' => 'array'
          }
        }
        value = described_class.new([parameter]).unpack(cookies)
        expect(value).to eq('Some' => %w[1 2])
      end

      it 'excludes key if paramter is not set' do
        cookies = ''
        parameter = {
          'in' => 'cookie',
          'name' => 'Some',
          'explode' => false,
          'schema' => {
            'type' => 'array'
          }
        }
        value = described_class.new([parameter]).unpack(cookies)
        expect(value).to eq({})
      end
    end

    describe 'Object explode true' do
      # NOTE: Nobody seems to understand how explode: true should work
      # So this library just ignores the explode flag for objects.

      it 'applies the "form" style by default' do
        cookies = 'Some=R=100,G=200,B=150;'
        parameter = {
          'in' => 'cookie',
          'name' => 'Some',
          'explode' => true,
          'schema' => {
            'type' => 'object'
          }
        }
        value = described_class.new([parameter]).unpack(cookies)
        expect(value).to eq(
          'Some' => {
            'R' => '100',
            'G' => '200',
            'B' => '150'
          }
        )
      end

      it 'excludes key if parameter is not set' do
        cookies = ''
        parameter = {
          'in' => 'cookie',
          'name' => 'Some',
          'explode' => true,
          'schema' => {
            'type' => 'object'
          }
        }
        value = described_class.new([parameter]).unpack(cookies)
        expect(value).to eq({})
      end

      it 'accepts the "form" style' do
        cookies = 'Some=R=100,G=200,B=150;'
        parameter = {
          'in' => 'cookie',
          'name' => 'Some',
          'explode' => true,
          'style' => 'form',
          'schema' => {
            'type' => 'object'
          }
        }
        value = described_class.new([parameter]).unpack(cookies)
        expect(value).to eq(
          'Some' => {
            'R' => '100',
            'G' => '200',
            'B' => '150'
          }
        )
      end

      it 'returns the unpacked value if value is malformated' do
        cookies = 'Some=R=100,G200,B=150;'
        parameter = {
          'in' => 'cookie',
          'name' => 'Some',
          'explode' => true,
          'schema' => {
            'type' => 'object'
          }
        }
        value = described_class.new([parameter]).unpack(cookies)
        expect(value).to eq('Some' => 'R=100,G200,B=150')
      end
    end

    describe 'Object explode false' do
      it 'applies the "simple" style and explode false by default' do
        cookies = 'Some=R,100,G,200,B,150;'
        parameter = {
          'in' => 'cookie',
          'name' => 'Some',
          'schema' => {
            'type' => 'object'
          }
        }
        value = described_class.new([parameter]).unpack(cookies)
        expect(value).to eq(
          'Some' => {
            'R' => '100',
            'G' => '200',
            'B' => '150'
          }
        )
      end

      it 'returns the unpacked value if value is malformated' do
        cookies = 'Some=R,100,G200,B,150;'
        parameter = {
          'in' => 'cookie',
          'name' => 'Some',
          'schema' => {
            'type' => 'object'
          }
        }
        value = described_class.new([parameter]).unpack(cookies)
        expect(value).to eq('Some' => 'R,100,G200,B,150')
      end

      it 'accepts the "simple" style' do
        cookies = 'Some=R,100,G,200,B,150;'
        parameter = {
          'in' => 'cookie',
          'name' => 'Some',
          'explode' => false,
          'style' => 'simple',
          'schema' => {
            'type' => 'object'
          }
        }
        value = described_class.new([parameter]).unpack(cookies)
        expect(value).to eq(
          'Some' => {
            'R' => '100',
            'G' => '200',
            'B' => '150'
          }
        )
      end
    end
  end
end
