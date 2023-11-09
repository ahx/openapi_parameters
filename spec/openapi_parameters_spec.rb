# frozen_string_literal: true

RSpec.describe OpenapiParameters do
  it 'has a version number' do
    expect(OpenapiParameters::VERSION).not_to be_nil
  end

  require 'zeitwerk'

  it 'is zeitwerk conform' do
    loader = described_class::LOADER
    expect { loader.eager_load(force: true) }.not_to raise_error
  end
end
