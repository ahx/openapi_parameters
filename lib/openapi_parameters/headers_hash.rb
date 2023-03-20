module OpenapiParameters
  class HeadersHash
    # This was copied from this Rack::Request PR: https://github.com/rack/rack/pull/1881
    # It is not yet released in Rack, so we copied it here.
    def initialize(env)
      @env = env
    end

    def [](k)
      @env[header_to_env_key(k)]
    end

    def key?(k)
      @env.key?(header_to_env_key(k))
    end

    def header_to_env_key(k)
      k = k.upcase
      k.tr!('-', '_')
      unless k == "CONTENT_LENGTH" || k == "CONTENT_TYPE"
        k = "HTTP_#{k}"
      end
      k
    end
  end
end
