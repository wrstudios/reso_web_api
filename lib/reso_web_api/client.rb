require_relative 'base_client'
require_relative 'authentication'
require_relative 'resources'

module ResoWebApi
  # Main class to run requests against a RESO Web API server.
  class Client < BaseClient
    include Resources

    option :auth

    def initialize(options = {})
      super(options)
      ensure_valid_auth_strategy!
    end

    # Headers to be send along with requests
    # @return [Hash] The request headers
    def headers
      super.merge({ accept: 'application/json' })
    end

    # Return the {Faraday::Connection} object for this client.
    # Yields the connection object being constructed (for customzing middleware).
    # @return [Faraday::Connection] The connection object
    def connection(&block)
      super do |conn|
        conn.use Authentication::Middleware, @auth
        yield conn if block_given?
      end
    end

    # Returns a proxied {OData4::Service} that attempts to ensure a  properly
    # authenticated and authorized connection
    # @return [OData4::Service] The service instance.
    def service
      @service ||= OData4::Service.new(connection)
    end

    private

    def ensure_valid_auth_strategy!
      if auth.is_a?(Hash)
        strategy = auth.delete(:strategy)
        if strategy.is_a?(Class) && strategy <= Authentication::AuthStrategy
          @auth = strategy.new(auth)
        else
          raise ArgumentError, "#{auth} is not a valid auth strategy"
        end
      end
    end
  end
end
