# frozen_string_literal: true

require 'rack'

module OpenapiParameters
  # Cookie parses OpenAPI cookie parameters from a cookie string.
  class Cookie
    # @param parameters [Array<Hash>] The OpenAPI parameter definitions.
    def initialize(parameters)
      @parameters = parameters
    end

    # @param cookie_string [String] The cookie string from the request. Example "foo=bar; baz=qux"
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

    ARRAY_DELIMER = ','
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
