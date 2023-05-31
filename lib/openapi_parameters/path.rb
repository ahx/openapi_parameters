# frozen_string_literal: true

require 'rack'

module OpenapiParameters
  # Parses OpenAPI path parameters from a route params Hash that is usually provided by your Rack webframework
  class Path
    # @param parameters [Array<Hash>] The OpenAPI path parameters.
    # @param convert [Boolean] Whether to convert the values to the correct type.
    def initialize(parameters, convert: true)
      @parameters = parameters
      @convert = convert
    end

    attr_reader :parameters

    # @param path_params [Hash] The path parameters from the Rack request. The keys are strings.
    def unpack(path_params)
      parameters.each_with_object({}) do |param, result|
        parameter = Parameter.new(param)
        next unless path_params.key?(parameter.name)

        result[parameter.name] = catch :skip do
          value = Unpacker.unpack_value(parameter, path_params[parameter.name])
          @convert ? Converter.call(value, parameter.schema) : value
        end
      end
    end
  end
end
