# frozen_string_literal: true

module OpenapiParameters
  # @visibility private
  class ObjectConverter < Data.define(:schema)
    def self.get_properties(schema)
      direct_props = schema['properties'] || {}

      combinations = schema.slice('allOf', 'oneOf', 'anyOf')
      if combinations.any?
        composition_props = combinations.values.flat_map { |value| value.map { |sub| sub['properties'] }.compact }
        return direct_props.merge({}.merge(*composition_props.compact)) unless composition_props.empty?
      end

      direct_props.empty? ? nil : direct_props
    end

    def call(value)
      return value unless value.is_a?(Hash)

      properties = ObjectConverter.get_properties(schema)

      value.each_with_object({}) do |(key, val), hsh|
        hsh[key] = Converter.convert(val, properties&.fetch(key, nil))
      end
    end
  end
end
