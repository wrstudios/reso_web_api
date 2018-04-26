module ResoWebApi
  module Authentication

    # This implements a basic token authentication, in which a username/password
    # (or API key / secret) combination is sent to a special token endpoint in
    # exchange for a HTTP Bearer token with a limited lifetime.
    class TokenAuth < BaseAuth

      def initialize(client)
        super(client)
      end

      def authenticate
        ResoWebApi.logger.debug { "Authenticating to #{@client.auth_url}" }

        params = {
          client_id:     @client.api_key,
          client_secret: @client.api_secret,
          grant_type:   'client_credentials',
          scope:         @client.auth_scope
        }
        response = @client.connection.post @client.auth_url, params
        ResoWebApi.logger.debug("Authentication Response: #{response.body}")
        body = JSON.parse response.body

        unless response.success?
          message = "#{response.reason_phrase}: #{body['error'] || response.body}"
          raise ClientError, status: response.status, message: message
        end

        @session = Session.new(body)
        ResoWebApi.logger.debug("Created session: #{@session.inspect}")

        @session
      end

      def logout
        @session = nil
      end

      def service
        if @service && authenticated?
          @service
        else
          authenticate
          @service = OData4::Service.new(@client.service_url, service_options)
          @service.logger = ResoWebApi.logger
          @service
        end
      end

      private

      def service_options
        {
          typhoeus: {
            headers: @client.headers.merge({
              'Authorization' => "#{session.token_type} #{session.access_token}"
            })
          }
        }
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
        Time.now > @expires
      end
    end
  end
end
