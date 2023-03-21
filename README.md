# OpenapiParameters

OpenapiParameters is an an [OpenAPI](https://www.openapis.org/) aware parameter parser.

OpenapiParameters unpacks HTTP/Rack (query / header / cookie) parameters exactly as described in an [OpenAPI](https://www.openapis.org/) definition. It supports `style`, `explode` and `schema` definitions according to OpenAPI 3.1.

## Synopsis

Note that OpenAPI supportes parameter definition on path and operation objects. Parameter definition must use strings as keys.

### Unpack query/path/header/cookie parameters from HTTP request according to their OpenAPI definition

```ruby
parameters = [
  'name' => 'ids',
  'required' => true,
  'in' => 'query', # or 'path', 'header', 'cookie'
  'schema' => {
    'type' => 'array',
    'items' => {
      'type' => 'integer'
    }
  }
]

query_parameters = OpenapiParameters::Query.new(parameters)
query_string = env['QUERY_STRING'] # => 'ids=1&ids=2'
query_parameters.unpack(query_string)

path_parameters = OpenapiParameters::Path.new(parameters, '/pets/ids')
path_info = env['PATH_INFO'] # => '/pets/1,2,3'
path_parameters.unpack(path_info) # => { 'ids' => [1, 2, 3] }

header_parameters = OpenapiParameters::Header.new(parameters)
header_parameters.unpack_env(env)

cookie_parameters = OpenapiParameters::Cookie.new(parameters)
cookie_string = env['HTTP_COOKIE'] # => "ids=3"
cookie_parameters.unpack(cookie_string) # => { 'ids' => [3] }
```

Note that this library does not validate the parameter value against it's JSON Schema.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add OpenapiParameters

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install OpenapiParameters

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ahx/OpenapiParameters.
