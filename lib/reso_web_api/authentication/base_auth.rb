module ResoWebApi
  module Authentication
    # This base class defines the basic interface support by all client authentication implementations.
    class BaseAuth
      attr_accessor :session

      # All inheriting classes should accept the reso_web_api client as part of initialization
      def initialize(client)
        @client = client
      end

      # Perform requests to authenticate the client with the API
      def authenticate
        raise NotImplementedError, "Implement me!"
      end

      # Called before running authenticate (except)
      def authenticated?
        !(session.nil? || session.expired?)
      end

      # Terminate the active session
      def logout
        raise NotImplementedError, "Implement me!"
      end

      # Return the authenticated OData service instance
      def service
        raise NotImplementedError, "Implement me!"
      end
    end
  end
end
