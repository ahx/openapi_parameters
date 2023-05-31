# frozen_string_literal: true

module OpenapiParameters
  # Header parses OpenAPI parameters from the request headers.
  class Header
    # @param parameters [Array<Hash>] The OpenAPI parameters
    # @param convert [Boolean] Whether to convert the values to the correct type.
    def initialize(parameters, convert: true)
      @parameters = parameters
      @convert = convert
    end

    # @param headers [Hash] The headers from the request. Use HeadersHash to convert a Rack env to a Hash.
    def unpack(headers)
      parameters.each_with_object({}) do |parameter, result|
        parameter = Parameter.new(parameter)
        next unless headers.key?(parameter.name)

        result[parameter.name] = catch :skip do
          value = Unpacker.unpack_value(parameter, headers[parameter.name])
          @convert ? Converter.call(value, parameter.schema) : value
        end
      end
    end

    def unpack_env(env)
      unpack(HeadersHash.new(env))
    end

    attr_reader :parameters
  end
end
