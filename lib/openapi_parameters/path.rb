# frozen_string_literal: true

require 'rack'

module OpenapiParameters
  # Parses OpenAPI path parameters from a route params Hash that is usually provided by your Rack webframework
  class Path
    # @param parameters [Array<Hash>] The OpenAPI path parameters.
    # @param convert [Boolean] Whether to convert the values to the correct type.
    def initialize(parameters, convert: true)
      @parameters = parameters
      @convert = convert
    end

    attr_reader :parameters

    # @param path_params [Hash] The path parameters from the Rack request. The keys are strings.
    def unpack(path_params)
      parameters.each_with_object({}) do |param, result|
        parameter = Parameter.new(param)
        next unless path_params.key?(parameter.name)

        result[parameter.name] = catch :skip do
          value = unpack_parameter(parameter, path_params)
          @convert ? Converter.call(value, parameter.schema) : value
        end
      end
    end

    private

    def unpack_parameter(parameter, parsed_path)
      unpack_value(parameter, parsed_path[parameter.name])
    end

    def unpack_value(parameter, value)
      return value if value.nil?
      return unpack_array(parameter, value) if parameter.array?
      return unpack_object(parameter, value) if parameter.object?

      value
    end

    def unpack_array(parameter, value)
      return value if value.empty?
      return unpack_matrix(parameter, value) if parameter.style == 'matrix'

      value = value[1..] if PREFIXED.key?(parameter.style)
      value.split(ARRAY_DELIMITER[parameter.style])
    end

    def unpack_matrix(parameter, value)
      result = Rack::Utils.parse_query(value, ';')[parameter.name]
      return result if parameter.explode?

      result.split(',')
    end

    def unpack_object(parameter, value)
      return Rack::Utils.parse_query(value, ',') if parameter.explode?

      array = unpack_array(parameter, value)
      throw :skip, value if array.length.odd?

      Hash[*array]
    end

    PREFIXED = {
      'label' => '.',
      'matrix' => ';'
    }.freeze

    ARRAY_DELIMITER = {
      'label' => '.',
      'simple' => ','
    }.freeze
    private_constant :ARRAY_DELIMITER
  end
end
