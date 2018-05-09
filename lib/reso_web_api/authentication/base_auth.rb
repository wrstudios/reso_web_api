require_relative '../base_client'

module ResoWebApi
  module Authentication
    # This base class defines the basic interface support by all client authentication implementations.
    class BaseAuth < BaseClient
      attr_reader :access

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

      # Ensure that a valid access token is present or raise an exception
      # @raise [ResoWebApi::Errors::AccessDenied] If authentication fails
      def ensure_valid_access!
        @access = authenticate unless access && access.valid?
        access
      end

      # Resets access
      def reset
        @access = nil
      end
    end
  end
end
