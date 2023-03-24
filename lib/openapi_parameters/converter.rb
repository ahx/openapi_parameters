# frozen_string_literal: true

module OpenapiParameters
  ##
  # Tries to convert a request parameter value (string) to the type specified in the JSON Schema.
  class Converter
    ##
    # @param input [String, Hash, Array] the value to convert
    # @param schema [Hash] the schema to use for conversion.
    def self.call(input, schema)
      new(input, schema).call
    end

    def initialize(input, schema)
      @input = input
      @root_schema = schema
    end

    def call
      convert(@input, @root_schema)
    end

    private

    def convert(value, schema)
      check_supported!(schema)
      return if value.nil?

      case type(schema)
      when 'integer'
        begin
          Integer(value)
        rescue StandardError
          value
        end
      when 'number'
        begin
          Float(value)
        rescue StandardError
          value
        end
      when 'boolean'
        if value == 'true'
          true
        else
          value == 'false' ? false : value
        end
      when 'object'
        convert_object(value, schema)
      when 'array'
        convert_array(value, schema)
      else
        value
      end
    end

    REF = '$ref'.freeze
    private_constant :REF

    def check_supported!(schema)
      return unless schema&.key?(REF)

      raise NotSupportedError,
            "$ref is not supported: #{@root_schema.inspect}"
    end

    def type(schema)
      schema && schema['type']
    end

    def convert_object(object, schema)
      object.each_with_object({}) do |(key, value), hsh|
        hsh[key] = convert(value, schema['properties']&.fetch(key))
      end
    end

    def convert_array(array, schema)
      item_schema = schema['items']
      prefix_schemas = schema['prefixItems']
      return convert_array_with_prefixes(array, prefix_schemas, item_schema) if prefix_schemas

      array.map { |item| convert(item, item_schema) }
    end

    def convert_array_with_prefixes(array, prefix_schemas, item_schema)
      prefixes =
        array
        .slice(0, prefix_schemas.size)
        .each_with_index
        .map { |item, index| convert(item, prefix_schemas[index]) }
      array =
        array[prefix_schemas.size..].map! do |item|
          convert(item, item_schema)
        end
      prefixes + array
    end
  end
end
