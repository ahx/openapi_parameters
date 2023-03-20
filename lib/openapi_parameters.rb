# frozen_string_literal: true

require 'zeitwerk'
loader = Zeitwerk::Loader.for_gem
loader.setup

# OpenapiParameters is a gem that parses OpenAPI parameters from Rack
module OpenapiParameters
end

require_relative 'openapi_parameters/errors'
