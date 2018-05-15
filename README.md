# ResoWebApi

A Ruby library to connects to MLS servers conforming to the [RESO Web API][reso-web-api] standard.

[reso-web-api]: https://www.reso.org/reso-web-api/

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

### Authentication

Instantiating an API client requires two things: an endpoint (i.e. service URL) and an authentication strategy.
You may either instantiate the auth strategy directly and pass it to the client constructor (in the `:auth` parameter), or you may choose to pass a nested hash with options for configuring the strategy instead, as below:

```ruby
require 'reso_web_api'

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
client.resources['OpenHouse'].first # Access the 'OpenHouse' collectionh
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/wrstudios/reso_web_api.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
