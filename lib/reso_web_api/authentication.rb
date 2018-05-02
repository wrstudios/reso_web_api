require 'reso_web_api/authentication/base_auth'
require 'reso_web_api/authentication/token_auth'

module ResoWebApi
  module Authentication
    # Authenticate the client using the current auth strategy.
    #
    # @return [Object] The session object when authentication succeeds
    # @raise [ResoWebApi::ClientError] when authentication fails
    def authenticate(*args)
      @access = @auth.authenticate(*args)
    end

    # Refresh the current access.
    def refresh
      @access = @auth.refresh(@access)
    end
  end
end
