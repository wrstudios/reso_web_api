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

    # Makes a request to the OData service, taking care of properly authenticating
    # and authorizing the connection, and retrying in case of errors.
    # @yield [OData4::Service] An {OData4::Service} object
    def request(&block)
      ensure_acess_is_valid

      handle_retryable_errors do
        yield service
      end
    end

    private

    # Returns the {OData4::Service} used by the client.
    # @return [OData4::Service] The service object.
    def service
      @service ||= OData4::Service.new(connection)
    end

    def ensure_acess_is_valid
      authenticate unless @access && @access.valid?
      connection.authorization(@access.token_type, @access.token)
    end

    def handle_retryable_errors(&block)
      attempts = 0
      begin
        yield
      rescue OData4::Errors::AccessDenied
        unless (attempts += 1) > 1
          authenticate
          retry
        else
          raise
        end
      end
    end
  end
end
