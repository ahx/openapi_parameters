# frozen_string_literal: true

require 'rack'

module OpenapiParameters
  # Query parses query parameters from a http query strings.
  class Query
    # @param parameters [Array<Hash>] The OpenAPI query parameter definitions.
    # @param convert [Boolean] Whether to convert the values to the correct type.
    def initialize(parameters, convert: true, rack_array_compat: false)
      @parameters = parameters.map { Parameter.new(_1) }
      @convert = convert
      @remove_array_brackets = rack_array_compat
    end

    def unpack(query_string) # rubocop:disable Metrics/AbcSize
      parsed_query = parse_query(query_string)
      parameters.each_with_object({}) do |parameter, result|
        if parameter.deep_object?
          parsed_nested_query = Rack::Utils.parse_nested_query(query_string)
          next unless parsed_nested_query.key?(parameter.name)

          value = parsed_nested_query[parameter.name]
        else
          next unless parsed_query.key?(parameter.name)

          value = Unpacker.unpack_value(parameter, parsed_query[parameter.name])
        end
        key = if remove_array_brackets && parameter.bracket_array?
                parameter.name.delete_suffix('[]')
              else
                parameter.name
              end
        result[key] = @convert ? parameter.convert(value) : value
      end
    end

    attr_reader :parameters
    private attr_reader :remove_array_brackets

    private

    def parse_query(query_string)
      Rack::Utils.parse_query(query_string) do |s|
        Rack::Utils.unescape(s)
      rescue ArgumentError => e
        raise Rack::Utils::InvalidParameterError, e.message
      end
    end

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
