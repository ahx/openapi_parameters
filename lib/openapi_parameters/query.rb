require 'rack'

module OpenapiParameters
  class Query
    def initialize(parameters)
      @parameters = parameters
    end

    def unpack(query_string) # rubocop:disable Metrics/AbcSize
      parsed_query = Rack::Utils.parse_query(query_string)

      parameters.each_with_object({}) do |parameter, result|
        parameter = Parameter.new(parameter)
        if parameter.style == 'deepObject' && parameter.object?
          parsed_nested_query = Rack::Utils.parse_nested_query(query_string)
          next unless parsed_nested_query.key?(parameter.name)
          result[parameter.name] = parsed_nested_query[parameter.name]
        else
          next unless parsed_query.key?(parameter.name)
          result[parameter.name] = unpack_parameter(parameter, parsed_query)
        end
      end
    end

    attr_reader :parameters

    private

    QUERY_PARAMETER_DELIMETER = '&'.freeze
    ARRAY_DELIMER = ','.freeze

    def unpack_parameter(parameter, parsed_query)
      return parsed_query[parameter.name] if parameter.primitive?
      return unpack_array(parameter, parsed_query) if parameter.array?
      return unpack_object(parameter, parsed_query) if parameter.object?
    end

    def unpack_array(parameter, parsed_query)
      return parsed_query[parameter.name] if parameter.explode?

      unless parameter.explode?
        parsed_query[parameter.name].split(array_delimiter(parameter.style))
      end
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
      'simple' => ',',
    }.freeze

    def array_delimiter(style)
      DELIMERS.fetch(style, ARRAY_DELIMER)
    end
  end
end
