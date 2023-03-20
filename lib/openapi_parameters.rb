# frozen_string_literal: true
require 'zeitwerk'
loader = Zeitwerk::Loader.for_gem
loader.setup

require_relative 'openapi_parameters/errors'

module OpenapiParameters
end
