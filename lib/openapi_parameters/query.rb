# frozen_string_literal: true

require 'rack'

module OpenapiParameters
  # Query parses query parameters from a http query strings.
  class Query
    # @param parameters [Array<Hash>] The OpenAPI query parameter definitions.
    # @param convert [Boolean] Whether to convert the values to the correct type.
    def initialize(parameters, convert: true)
      @parameters = parameters
      @convert = convert
    end

    def unpack(query_string) # rubocop:disable Metrics/AbcSize
      parsed_query = Rack::Utils.parse_query(query_string)
      parameters.each_with_object({}) do |parameter, result|
        parameter = Parameter.new(parameter)
        if parameter.style == 'deepObject' && parameter.object?
          parsed_nested_query = Rack::Utils.parse_nested_query(query_string)
          next unless parsed_nested_query.key?(parameter.name)

          result[parameter.name] = convert(parsed_nested_query[parameter.name], parameter)
        else
          next unless parsed_query.key?(parameter.name)

          value = Unpacker.unpack_value(parameter, parsed_query[parameter.name])
          result[parameter.name] = convert(value, parameter)
        end
      end
    end

    attr_reader :parameters

    private

    def convert_primitive(value, parameter)
      return value unless @convert
      return value if value == ''

      Converter.convert_primitive(value, parameter.schema)
    end

    def convert(value, parameter)
      return value unless @convert
      return value if value == ''

      Converter.convert(value, parameter.schema)
    end
  end
end
