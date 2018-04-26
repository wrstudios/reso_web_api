require 'reso_web_api/authentication/base_auth'
require 'reso_web_api/authentication/token_auth'

module ResoWebApi
  module Authentication
    # Main authentication step.
    # Runs before any API request unless the user session exists and is still valid.
    #
    # @return [Object] The session object when authentication succeeds
    # @raise [ResoWebApi::ClientError] when authentication fails
    def authenticate
      start_time = Time.now
      new_session = @authenticator.authenticate
      request_time = Time.now - start_time

      ResoWebApi.logger.info { "[#{(request_time * 1000).to_i}ms]" }
      ResoWebApi.logger.debug { "Session: #{new_session.inspect}" }

      new_session
    end

    # Checks if there is an active session
    def authenticated?
      @authenticator.authenticated?
    end

    # Close the current session
    def logout
      ResoWebApi.logger.info { "Logging out." }
      @authenticator.logout
    end

    # Return the active session object
    def session
      @authenticator.session
    end

    # Set the active session object
    def session=(session)
      @authenticator.session = session
    end

    # Obtain the authenticated OData service instance
    def service
      @authenticator.service
    end
  end
end
