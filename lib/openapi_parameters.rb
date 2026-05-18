# frozen_string_literal: true

require 'json'
require 'rack'
require_relative 'openapi_parameters/converters'
require_relative 'openapi_parameters/converter'
require_relative 'openapi_parameters/cookie'
require_relative 'openapi_parameters/error'
require_relative 'openapi_parameters/header'
require_relative 'openapi_parameters/headers_hash'
require_relative 'openapi_parameters/not_supported_error'
require_relative 'openapi_parameters/content_parsers'
require_relative 'openapi_parameters/unpackers'
require_relative 'openapi_parameters/parameter'
require_relative 'openapi_parameters/path'
require_relative 'openapi_parameters/query'

# OpenapiParameters is a gem that parses OpenAPI parameters from Rack
module OpenapiParameters
end
