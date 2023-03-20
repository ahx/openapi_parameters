module OpenapiParameters
  class Header
    def initialize(parameters)
      @parameters = parameters
    end

    def unpack(headers)
      parameters.each_with_object({}) do |parameter, result|
        parameter = Parameter.new(parameter)
        next unless headers.key?(parameter.name)
        result[parameter.name] = unpack_parameter(parameter, headers)
      end
    end

    def unpack_env(env)
      unpack(HeadersHash.new(env))
    end

    attr_reader :parameters

    private

    def unpack_parameter(parameter, headers)
      value = headers[parameter.name]
      return value if parameter.primitive?
      return unpack_object(parameter, value) if parameter.object?
      return unpack_array(value) if parameter.array?
    end

    def unpack_array(value)
      value.split(ARRAY_DELIMER)
    end

    ARRAY_DELIMER = ','.freeze
    OBJECT_EXPLODE_SPLITTER = Regexp.union(',', '=').freeze

    def unpack_object(parameter, value)
      entries =
        if parameter.explode?
          value.split(OBJECT_EXPLODE_SPLITTER)
        else
          value.split(ARRAY_DELIMER)
        end
      return value if entries.length.odd?
      Hash[*entries]
    end
  end
end
