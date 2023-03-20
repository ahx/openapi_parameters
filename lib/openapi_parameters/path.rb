require 'uri_template'

module OpenapiParameters
  class Path
    def initialize(parameters, path)
      @parameters = parameters
      @path = path
    end

    attr_reader :parameters, :path

    def unpack(path_info) # rubocop:disable Metrics/AbcSize
      parsed_path = URITemplate.new(url_template).extract(path_info) || {}
      parameters.each_with_object(parsed_path) do |parameter, result|
        param = Parameter.new(parameter)
        next unless parsed_path.key?(param.name)
        if param.object? && result[param.name].is_a?(Array)
          result[param.name] = array_to_hash(result[param.name])
        end
      end
    end

    def url_template
      @url_template ||=
        begin
          path = @path.dup
          parameters.each do |p|
            param = Parameter.new(p)
            if param.array? || param.object?
              path.gsub!(
                "{#{param.name}}",
                "{#{operator(param)}#{param.name}#{modifier(param)}}",
              )
            end
          end
          path
        end
    end

    private

    def array_to_hash(array)

      return array if array&.length&.odd?

      Hash[*array]
    end

    LIST_OPS = { 'simple' => nil, 'label' => '.', 'matrix' => ';' }
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
