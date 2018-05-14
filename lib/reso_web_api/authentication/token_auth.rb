module ResoWebApi
  module Authentication
    # This implements a basic token authentication, in which a username/password
    # (or API key / secret) combination is sent to a special token endpoint in
    # exchange for a HTTP Bearer token with a limited lifetime.
    class TokenAuth < AuthStrategy
      option :client_id
      option :client_secret
      option :grant_type, default: proc { 'client_credentials' }
      option :scope

      def authenticate
        response = connection.post nil, auth_params
        body = JSON.parse response.body

        unless response.success?
          message = "#{response.reason_phrase}: #{body['error'] || response.body}"
          raise Errors::AccessDenied, response: response, message: message
        end

        Access.new(body)
      end

      def connection
        super.basic_auth(client_id, client_secret) && super
      end

      private

      def auth_params
        {
          client_id:     client_id,
          client_secret: client_secret,
          grant_type:    grant_type,
          scope:         scope
        }
      end
    end
  end
end
