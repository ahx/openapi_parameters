# frozen_string_literal: true

require_relative 'lib/openapi_parameters/version'

Gem::Specification.new do |spec|
  spec.name = 'openapi_parameters'
  spec.version = OpenapiParameters::VERSION
  spec.authors = ['Andreas Haller']
  spec.email = ['andreas.haller@posteo.de']

  spec.summary = 'openapi_parameters is an OpenAPI aware parameter parser'
  spec.description =
    'This parses HTTP query/path/header/cookie parameters exactly as described in an OpenAPI API description.'
  spec.homepage = 'https://github.com/ahx/openapi_parameters'
  spec.required_ruby_version = '>= 3.1.0'
  spec.licenses = ['MIT']

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/ahx/openapi_parameters'
  spec.metadata[
    'changelog_uri'
  ] = 'https://github.com/ahx/openapi_parameters/blob/main/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir['{lib}/**/*.rb', 'LICENSE.txt', 'README.md', 'CHANGELOG.md']
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'rack', '>= 2.2'

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
  spec.metadata['rubygems_mfa_required'] = 'true'
end
