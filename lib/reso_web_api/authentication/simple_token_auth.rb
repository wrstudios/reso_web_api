module ResoWebApi
  module Authentication
    # A simple auth strategy that uses a static, non-expiring token.
    class SimpleTokenAuth < AuthStrategy
      # The access token (String)
      option :access_token
      # The token type (String, defaults to `Bearer`)
      option :token_type, default: proc { 'Bearer' }
      # This strategy does not require an endpoint
      option :endpoint, optional: true

      # Simply returns a static, never expiring access token
      # @return [Access] The access token object
      def authenticate
        Access.new(
          'access_token' => access_token,
          'token_type'   => token_type,
          'expires_in'   => 1 << (1.size * 8 - 2) - 1 # Max int value
        )
      end
    end
  end
end
