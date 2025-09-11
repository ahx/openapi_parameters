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
      @any_deep_object = @parameters.any?(&:deep_object?)
    end

    def unpack(query_string) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
      parsed_query = parse_query(query_string)
      parsed_nested_query = Rack::Utils.parse_nested_query(query_string) if any_deep_object?
      parameters.each_with_object({}) do |parameter, result|
        if parameter.deep_object?
          next unless parsed_nested_query.key?(parameter.name)

          value = if parameter.explode?
                    handle_deep_object_explode(parameter, parsed_nested_query[parameter.name], parsed_query)
                  else
                    parsed_nested_query[parameter.name]
                  end
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

    def any_deep_object?
      @any_deep_object
    end

    def parse_query(query_string)
      Rack::Utils.parse_query(query_string) do |s|
        Rack::Utils.unescape(s)
      rescue ArgumentError => e
        raise Rack::Utils::InvalidParameterError, e.message
      end
    end

    def handle_deep_object_explode(parameter, value, parsed_query)
      return value unless value.is_a?(Hash)

      schema_props = parameter.schema['properties'] || {}

      array_prop_values = find_prop_matches(parameter.name, schema_props, parsed_query)

      schema_props.each_with_object(value) do |(prop, prop_schema), result|
        next unless prop_schema['type'] == 'array'

        arr = array_prop_values[prop]
        result[prop] = if arr.empty? && value.key?(prop)
                         Array(value[prop])
                       else
                         arr
                       end
      end
    end

    def find_prop_matches(parameter_name, schema_props, parsed_query)
      schema_props.each_key.with_object({}) do |prop, result|
        key = "#{parameter_name}[#{prop}]"
        value = Array(parsed_query[key])
        result[prop] = value.map { |match| Rack::Utils.unescape(match) } if value.is_a?(Array)
      end
    end
  end
end
