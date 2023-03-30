# frozen_string_literal: true

require_relative 'lib/openapi_parameters/version'

Gem::Specification.new do |spec|
  spec.name = 'openapi_parameters'
  spec.version = OpenapiParameters::VERSION
  spec.authors = ['Andreas Haller']
  spec.email = ['andreas.haller@posteo.de']

  spec.summary = 'OpenapiParameters is an OpenAPI aware parameter parser'
  spec.description =
    'OpenapiParameters parses HTTP query/path/header/cookie parameters exactly as described in an OpenAPI API description.'
  spec.homepage = 'https://github.com/ahx/OpenapiParameters'
  spec.required_ruby_version = '>= 3.1.0'
  spec.licenses = ['MIT']

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/ahx/OpenapiParameters'
  spec.metadata[
    'changelog_uri'
  ] = 'https://github.com/ahx/openapi_parameters/blob/main/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files =
    Dir.chdir(__dir__) do
      `git ls-files -z`.split("\x0")
                       .reject do |f|
        (f == __FILE__) ||
          f.match(
            %r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)}
          )
      end
    end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'rack', '>= 2.2'
  spec.add_dependency 'zeitwerk', '~> 2.6'

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
  spec.metadata['rubygems_mfa_required'] = 'true'
end
