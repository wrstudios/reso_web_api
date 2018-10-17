# ResoWebApi

A Ruby library to connects to MLS servers conforming to the [RESO Web API][reso-web-api] standard.

[reso-web-api]: https://www.reso.org/reso-web-api/

[![Gem Version](https://badge.fury.io/rb/reso_web_api.svg)](https://badge.fury.io/rb/reso_web_api)
[![Build Status](https://app.codeship.com/projects/c9f88f50-3a07-0136-6878-6eab29180a68/status?branch=master)](https://app.codeship.com/projects/290070)
[![Test Coverage](https://api.codeclimate.com/v1/badges/6e707a367bfdd609fc76/test_coverage)](https://codeclimate.com/github/wrstudios/reso_web_api/test_coverage)
[![Maintainability](https://api.codeclimate.com/v1/badges/6e707a367bfdd609fc76/maintainability)](https://codeclimate.com/github/wrstudios/reso_web_api/maintainability)
[![Documentation](http://inch-ci.org/github/wrstudios/reso_web_api.png?branch=master)](http://www.rubydoc.info/github/wrstudios/reso_web_api/master)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'reso_web_api'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install reso_web_api

## Usage

### Quickstart

Instantiating an API client requires two things: an endpoint (i.e. service URL) and an authentication strategy.

```ruby
require 'reso_web_api'

client = ResoWebApi::Client.new(endpoint: '<Service URL>', auth: auth)
```

The `:endpoint` option should need no further explanation, for `:auth`, read on below.

### Authentication

You may either instantiate the auth strategy directly and pass it to the client constructor (in the `:auth` parameter), or you may choose to pass a nested hash with options for configuring the strategy instead, as below:

```ruby
client = ResoWebApi::Client.new(
  endpoint: 'https://api.my-mls.org/RESO/OData/',
  auth: {
    strategy:      ResoWebApi::Authentication::TokenAuth,
    endpoint:      'https://oauth.my-mls.org/connect/token',
    client_id:     'deadbeef',
    client_secret: 'T0pS3cr3t',
    scope:         'odata'
  }
end
```

Note that if you choose this option, you _may_ specify the strategy implementation by passing its _class_ as the `:strategy` option.
If you omit the `:strategy` parameter, it will default to `ResoWebApi::Authentication::TokenAuth`.

For a list of available authentication strategies and usage examples, please [see below](#authentication-strategies).

### Advanced Configuration

The client is designed to work out-of-the-box and require as little configuration as possible (only endpoint and auth by default).
However, if you need more control, there are several additional settings that can be configured using the constructor.

- `:user_agent`: Sets the `User-Agent` header sent to the service (defaults to `Reso Web API Ruby Gem $VERSION`)
- `:adapter`: Sets the Faraday adapter used for the connection (defaults to `Net::HTTP`)
- `:headers`: Allows custom headers to be set on the connection. 
- `:logger`: You may pass your own logger to a client instance. By default, each instance will use the global logger defined on the `ResoWebApi` module, which logs to STDOUT. You can also change the logger on the module itself, which will then be used for all new client instances you create.
- `:odata`: If you need to pass any special options to the OData service, you may do so here.

### Accessing Data

#### Standard Resources

Since most RESO Web API servers will likely adhere to the RESO Data Dictionary, we've created some shortcuts for the standard resources

```ruby
# Iterate over all properties -- WARNING! Might take a long time
client.properties.each do |property|
  puts "#{property['ListPrice']} #{property['StandardStatus']}"
end
```

The following methods are provided:

- Property: use `#properties`
- Member: use `#members`
- Office: use `#office`
- Media: use `#media`

#### Other Resources

Other resources may be access using the `#resources` method on the client, which may be accessed as a hash like this:

```ruby
client.resources['OpenHouse'].first # Access the 'OpenHouse' collection
```

## Authentication Strategies

Since the details of authentication may vary from vendor to vendor, this gem attempts to stay flexible by providing a modular authentication system.

### Available Strategies

Currently, we provide the following authentication strategies:

#### `SimpleTokenAuth`

A simple strategy that works with a static access token. Often used for development access, where security is not a major concern.

##### Configuration

- `access_token`: The access token value (`String`).
- `token_type`: The token type (`String`, optional). Defaults to `Bearer`.

##### Example

```ruby
client = ResoWebApi::Client.new(
  endpoint: 'https://api.my-mls.org/RESO/OData/',
  auth: {
    strategy: ResoWebApi::Authentication::SimpleTokenAuth,
    access_token: 'abcdefg01234567890'
  }
)
```

#### `TokenAuth`

A basic OAuth-based token strategy, where a Client ID/Secret pair is sent to a server in exchange for a temporary access token. Frequently used in production systems for its increased security over the static token strategy.

##### Configuration

- `endpoint`: The URL of the token server (`String`).
- `client_id`: The Client ID (`String`).
- `client_secret`: The Client Secret (`String`).
- `scope`: The scope for the token (`String`).
- `grant_type`: The grant type (`String`, optional). Defaults to `client_credentials`.

##### Example

```ruby
client = ResoWebApi::Client.new(
  endpoint: 'https://api.my-mls.org/RESO/OData/',
  auth: {
    strategy:      ResoWebApi::Authentication::TokenAuth,
    endpoint:      'https://oauth.my-mls.org/connect/token',
    client_id:     'deadbeef',
    client_secret: 'T0pS3cr3t',
    scope:         'odata'
  }
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/wrstudios/reso_web_api.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
