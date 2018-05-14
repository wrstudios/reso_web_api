module ResoWebApi
  module Authentication
    # This base class defines the basic interface support by all client authentication implementations.
    class AuthStrategy < BaseClient
      attr_reader :access

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
