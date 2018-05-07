require_relative 'base_client'
require_relative 'service_proxy'

module ResoWebApi
  # Main class to run requests against a RESO Web API server.
  class Client < BaseClient
    attr_accessor :access

    # Creates a new API client.
    def initialize(endpoint:, auth:, user_agent: USER_AGENT, adapter: ADAPTER)
      super(endpoint: endpoint, user_agent: user_agent, adapter: adapter)
      @auth = auth
    end

    # Authenticate the client using the current auth strategy.
    def authenticate(*args)
      @access = @auth.authenticate(*args)
    end

    # Refresh the current access.
    def refresh
      @access = @auth.refresh(@access)
    end

    # Headers to be send along with requests
    # @return [Hash] The request headers
    def headers
      super.merge({ accept: 'application/json' })
    end

    # Returns a proxied {OData4::Service} that attempts to ensure a  properly
    # authenticated and authorized connection
    # @return [ResoWebApi::ServiceProxy] The service proxy.
    def service
      @service ||= ServiceProxy.new(self)
    end
  end
end
