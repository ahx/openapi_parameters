# frozen_string_literal: true

require 'zeitwerk'

# OpenapiParameters is a gem that parses OpenAPI parameters from Rack
module OpenapiParameters
  LOADER = Zeitwerk::Loader.for_gem
  LOADER.setup
end
