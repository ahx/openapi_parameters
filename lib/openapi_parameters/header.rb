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
          value = unpack_parameter(parameter, headers)
          @convert ? Converter.call(value, parameter.schema) : value
        end
      end
    end

    def unpack_env(env)
      unpack(HeadersHash.new(env))
    end

    attr_reader :parameters

    private

    def unpack_parameter(parameter, headers)
      value = headers[parameter.name]
      return value if parameter.primitive?
      return unpack_object(parameter, value) if parameter.object?
      return unpack_array(value) if parameter.array?
    end

    def unpack_array(value)
      value.split(ARRAY_DELIMER)
    end

    ARRAY_DELIMER = ','
    OBJECT_EXPLODE_SPLITTER = Regexp.union(',', '=').freeze

    def unpack_object(parameter, value)
      entries =
        if parameter.explode?
          value.split(OBJECT_EXPLODE_SPLITTER)
        else
          value.split(ARRAY_DELIMER)
        end
      throw :skip, value if entries.length.odd?

      Hash[*entries]
    end
  end
end
