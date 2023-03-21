# frozen_string_literal: true

require 'uri_template'

module OpenapiParameters
  # Parses OpenAPI path parameters from path template strings and the request path.
  class Path
    # @param parameters [Array<Hash>] The OpenAPI path parameters.
    # @param path [String] The OpenAPI path template string.
    # @param convert [Boolean] Whether to convert the values to the correct type.
    def initialize(parameters, path, convert: true)
      @parameters = parameters
      @path = path
      @convert = convert
    end

    attr_reader :parameters, :path

    def unpack(path_info)
      parsed_path = URITemplate.new(url_template).extract(path_info) || {}
      parameters.each_with_object(parsed_path) do |param, result|
        parameter = Parameter.new(param)
        next unless parsed_path.key?(parameter.name)

        result[parameter.name] = catch :skip do
          value = unpack_parameter(parameter, result)
          @convert ? Converter.call(value, parameter.schema) : value
        end
      end
    end

    def unpack_parameter(parameter, parsed_path)
      value = parsed_path[parameter.name]
      if parameter.object? && value.is_a?(Array)
        throw :skip, value if value.length.odd?
        return Hash[*value]
      end
      value
    end

    def url_template
      @url_template ||=
        begin
          path = @path.dup
          parameters.each do |p|
            param = Parameter.new(p)
            next unless param.array? || param.object?

            path.gsub!(
              "{#{param.name}}",
              "{#{operator(param)}#{param.name}#{modifier(param)}}"
            )
          end
          path
        end
    end

    private

    LIST_OPS = { 'simple' => nil, 'label' => '.', 'matrix' => ';' }.freeze
    private_constant :LIST_OPS

    def operator(param)
      LIST_OPS[param.style]
    end

    def modifier(param)
      return '*' if param.explode?
      return if param.style == 'matrix' && !param.explode?
    end
  end
end
