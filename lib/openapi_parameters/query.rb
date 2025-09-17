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

    def unpack(query_string) # rubocop:disable Metrics/AbcSize
      parsed_query = parse_query(query_string)
      parameters.each_with_object({}) do |parameter, result|
        if parameter.deep_object?
          value = parse_deep_object(parameter, parsed_query)
          next if value.empty?
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

    def parse_deep_object(parameter, parsed_query)
      schema_props = parameter.schema['properties'] || {}
      name = parameter.name
      schema_props.each.with_object({}) do |(prop, schema), result|
        key = "#{name}[#{prop}]"
        next unless parsed_query.key?(key)

        value = explode_value(parsed_query[key], parameter, schema)
        result[prop] = value
      end
    end

    def explode_value(value, parameter, schema)
      type = schema['type']
      value = Array(value).map! { |v| Rack::Utils.unescape(v) }
      if type == 'array'
        return value if parameter.explode?

        return [value.last]
      end
      value.last
    end
  end
end
