## [Unreleased]

- Remove zeitwerk. It's awesome, but not needed here

## [0.3.2] - 2023-11-14

- Assume that schemas with `properties` or `style: deepObject` describe Objects and therefore convert it's values.

## [0.3.1] - 2023-11-09

- Make it work with Zeitwerk's `eager_load`

## [0.3.0] - 2023-10-27

- Query parameters: Don't attempt to convert arras within deepObject objects. Behaviour is not defined in OpenApi 3.1.

## [0.2.2] - 2023-06-01

- Remove superflous validation of "in" property
- Remove superfluous check for unsupported $ref inside parameter schema

## [0.2.1] - 2023-03-31

- Fix links in gemspec

## [0.2.0] - 2023-03-30

- Breaking: Path parameters are unpacked from a hash, which is usually available from the used Rack web framework. This is much simpler and more performant.

## [0.1.0] - 2023-03-25

- Initial release
