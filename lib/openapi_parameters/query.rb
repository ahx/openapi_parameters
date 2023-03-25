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

          unpacked = unpack_parameter(parameter, parsed_query)
          result[parameter.name] = convert(unpacked, parameter)
        end
      end
    end

    attr_reader :parameters

    private

    def convert(value, parameter)
      return value unless @convert
      return value if value == ''

      Converter.call(value, parameter.schema)
    end

    QUERY_PARAMETER_DELIMETER = '&'
    ARRAY_DELIMER = ','

    def unpack_parameter(parameter, parsed_query)
      value = parsed_query[parameter.name]
      return value if parameter.primitive? || value.nil?
      return unpack_array(parameter, parsed_query) if parameter.array?
      return unpack_object(parameter, parsed_query) if parameter.object?
    end

    def unpack_array(parameter, parsed_query)
      value = parsed_query[parameter.name]
      return value if value.empty?
      return Array(value) if parameter.explode?

      value.split(array_delimiter(parameter.style))
    end

    def unpack_object(parameter, parsed_query)
      return parsed_query[parameter.name] if parameter.explode?

      array = parsed_query[parameter.name]&.split(ARRAY_DELIMER)
      return array if array.length.odd?

      Hash[*array]
    end

    DELIMERS = {
      'pipeDelimited' => '|',
      'spaceDelimited' => ' ',
      'form' => ',',
      'simple' => ','
    }.freeze

    def array_delimiter(style)
      DELIMERS.fetch(style, ARRAY_DELIMER)
    end
  end
end
