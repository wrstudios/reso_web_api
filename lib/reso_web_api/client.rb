require_relative 'base_client'

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

    # Returns the (authorized) connection object.
    # @return [Faraday::Connection] The connection object
    def connection
      authenticate unless @access && @access.valid?
      super.authorization(@access.token_type, @access.token) && super
    end

    # Returns the {OData4::Service} object for OData access
    # @return [OData4::Service] The service object
    def service
      @service ||= OData4::Service.new(connection)
    end

    private

    def ensure_acess_is_valid
      refresh if @access.expired? && @auth && @auth.refreshable?(@access)
    end

    def handle_retryable_errors
      response = yield
      # TODO rescue from retryable errors
    end
  end
end
