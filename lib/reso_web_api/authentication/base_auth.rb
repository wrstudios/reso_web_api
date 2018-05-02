require_relative '../base_client'

module ResoWebApi
  module Authentication
    # This base class defines the basic interface support by all client authentication implementations.
    class BaseAuth < BaseClient
      attr_accessor :session

      def initialize(api_key:, api_secret:, endpoint:, user_agent: USER_AGENT)
        super(endpoint: endpoint, user_agent: user_agent)
        @api_key    = api_key
        @api_secret = api_secret
      end

      # @abstract Perform requests to authenticate the client with the API
      # @return [Access] The access token object
      def authenticate(*)
        raise NotImplementedError, 'Implement me!'
      end

      # @return [Boolean] Whether the access object can be refreshed
      # @param access [Access|String] the access to refresh
      def refreshable?(access)
        false
      end

      # @abstract Refresh the authentication and return the refreshed access
      # @param access [Access|String] the access to refresh
      def refresh(access)
        raise NotImplementedError, 'Implement Me!'
      end
    end
  end
end
