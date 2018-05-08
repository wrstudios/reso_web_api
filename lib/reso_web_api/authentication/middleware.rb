module ResoWebApi
  module Authentication
    # Authentication middleware
    # Ensures that each request is made with proper `Authorization` header set
    # and raises an exception if a request yields a `401 Access Denied` response.
    class Middleware < Faraday::Middleware
      AUTH_HEADER = 'Authorization'.freeze

      def initialize(app, auth)
        super(app)
        @auth = auth
      end

      def call(request_env)
        authorize_request(request_env)

        @app.call(request_env).on_complete do |response_env|
          check_authorization_status(response_env)
        end
      end

      private

      def authorize_request(request_env)
        @auth.ensure_valid_access!

        request_env[:request_headers].merge!(
          AUTH_HEADER => "#{@auth.access.token_type} #{@auth.access.token}"
        )
      end

      def check_authorization_status(response_env)
        # TODO: raise specific error class
        raise Errors::AccessDenied if response_env[:status] == 401
      end
    end
  end
end
