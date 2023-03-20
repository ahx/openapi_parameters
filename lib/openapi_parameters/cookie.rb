require 'rack'

module OpenapiParameters
  class Cookie
    def initialize(parameters)
      @parameters = parameters
    end

    def unpack(cookie_string)
      cookies = Rack::Utils.parse_cookies_header(cookie_string)
      parameters.each_with_object({}) do |parameter, result|
        parameter = Parameter.new(parameter)
        next unless cookies.key?(parameter.name)
        result[parameter.name] = unpack_parameter(parameter, cookies)
      end
    end

    private

    attr_reader :parameters

    def unpack_parameter(parameter, cookies)
      value = cookies[parameter.name]
      return if value.nil?
      return unpack_object(parameter, value) if parameter.object?
      return unpack_array(value) if parameter.array?

      value
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
