require_relative 'base_auth'

module ResoWebApi
  module Authentication
    # This implements a basic token authentication, in which a username/password
    # (or API key / secret) combination is sent to a special token endpoint in
    # exchange for a HTTP Bearer token with a limited lifetime.
    class TokenAuth < BaseAuth
      attr_reader :grant_type, :scope

      def initialize(endpoint:, api_key:, api_secret:, grant_type: 'client_credentials', scope:)
        super(endpoint: endpoint, api_key: api_key, api_secret: api_secret)
        @grant_type = grant_type
        @scope      = scope
      end

      def authenticate
        response = connection.post nil, auth_params
        body = JSON.parse response.body

        unless response.success?
          message = "#{response.reason_phrase}: #{body['error'] || response.body}"
          raise ClientError, status: response.status, message: message
        end

        Session.new(body)
      end

      private

      def auth_params
        {
          client_id:     @api_key,
          client_secret: @api_secret,
          grant_type:    grant_type,
          scope:         scope
        }
      end

      def connection
        super.basic_auth(@api_key, @api_secret) && super
      end
    end

    # Session class for TokenAuth. This stores the access token, the token type
    # (usually `Bearer`), and the expiration date of the token.
    class Session
      attr_accessor :access_token, :expires, :token_type

      def initialize(options = {})
        @access_token = options['access_token']
        @expires      = Time.now + options['expires_in']
        @token_type   = options['token_type']
      end

      def expired?
        Time.now > expires
      end

      def valid?
        access_token && !expired?
      end
    end
  end
end
