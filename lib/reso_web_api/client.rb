require_relative 'base_client'
require_relative 'authentication'
require_relative 'resources'

module ResoWebApi
  # Main class to run requests against a RESO Web API server.
  class Client < BaseClient
    include Resources

    # Auth strategy (class instance or Hash)
    option :auth
    # Options for OData service
    option :odata, optional: true

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

    # Returns a proxied {FrOData::Service} that attempts to ensure a  properly
    # authenticated and authorized connection
    # @return [FrOData::Service] The service instance.
    def service
      # puts odata, service_options
      @service ||= FrOData::Service.new(connection, service_options)
    end

    # Returns the default options used by the by the OData service
    # @return [Hash] The options hash
    def service_options
      @service_options ||= { logger: logger }.merge(odata || {})
    end

    private

    def ensure_valid_auth_strategy!
      if auth.is_a?(Hash)
        strategy = auth.delete(:strategy) || Authentication::TokenAuth
        if strategy.is_a?(Class) && strategy <= Authentication::AuthStrategy
          @auth = strategy.new(auth)
        else
          raise ArgumentError, "#{strategy} is not a valid auth strategy"
        end
      end
    end
  end
end
