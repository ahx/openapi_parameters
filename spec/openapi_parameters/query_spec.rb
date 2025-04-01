# frozen_string_literal: true

require 'yaml'

RSpec.describe OpenapiParameters::Query do
  tests = YAML.load_file(File.expand_path('./query-parameter-tests.yaml', __dir__))

  describe '#unpack' do
    tests.each do |test|
      description, parameter, query_string, unpacked_value, = test.values_at('description', 'parameter',
                                                                             'query_string', 'unpacked_value')
      it description do
        options = test['options'].to_h.transform_keys!(&:to_sym)
        value = described_class.new([parameter], **options).unpack(query_string)
        expect(value).to eq(unpacked_value)
      end
    end
  end
end
