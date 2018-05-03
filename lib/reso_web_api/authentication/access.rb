module ResoWebApi
  module Authentication
    # Session class for TokenAuth. This stores the access token, the token type
    # (usually `Bearer`), and the expiration date of the token.
    class Access
      attr_accessor :token, :expires, :token_type

      def initialize(options = {})
        @token      = options['access_token']
        @expires    = Time.now + options['expires_in']
        @token_type = options['token_type']
      end

      def expired?
        Time.now > expires
      end

      def valid?
        !!token && !expired?
      end
    end
  end
end
