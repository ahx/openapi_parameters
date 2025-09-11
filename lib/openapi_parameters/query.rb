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

          value = handle_deep_object_arrays(parameter, query_string, parsed_nested_query[parameter.name])
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

    # Handles deepObject array properties based on explode?
    def handle_deep_object_arrays(parameter, query_string, value) # rubocop:disable Metrics/AbcSize
      return value unless value.is_a?(Hash)

      schema_props = parameter.schema['properties'] || {}
      schema_props.each_with_object(value.dup) do |(prop, prop_schema), result|
        next unless prop_schema['type'] == 'array'

        matches = query_string.scan(/#{Regexp.escape(parameter.name)}\[#{Regexp.escape(prop)}\]=([^&]*)/)
        arr = matches.map { |m| Rack::Utils.unescape(m[0]) }
        result[prop] = if arr.empty? && value.key?(prop)
                         value[prop].is_a?(Array) ? value[prop] : [value[prop]].compact
                       else
                         parameter.explode? ? arr : arr.last
                       end
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
  end
end
