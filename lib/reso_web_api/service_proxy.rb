module ResoWebApi
  # A proxy service class. Wraps a {OData4::Service} and ensures that all
  # HTTP requests are made with proper authorization.
  class ServiceProxy
    # Creates a new proxy instance, given the {OData4::Service} instance to proxy to.
    # @param client [ResoWebApi::Client] The client object taking care of authentication.
    # @param service [OData4::Service] The service object to use (optional).
    def initialize(client, service = nil)
      @client  = client
      @service = service
    end

    private

    def method_missing(method, *args)
      request do |service|
        service.send(method, *args)
      end
    end

    def respond_to?(method)
      service.respond_to?(method)
    end

    def service
      @service ||= OData4::Service.new(@client.connection)
    end

    # Makes a request to the OData service, taking care of properly authenticating
    # and authorizing the connection, and retrying in case of errors.
    # @yield [OData4::Service] An {OData4::Service} object
    def request(&block)
      ensure_acess_is_valid

      handle_retryable_errors do
        yield service
      end
    end

    def ensure_acess_is_valid
      @client.authenticate unless @client.access && @client.access.valid?
      @client.connection.authorization(@client.access.token_type, @client.access.token)
    end

    def handle_retryable_errors(&block)
      attempts = 0
      begin
        yield
      rescue OData4::Errors::AccessDenied
        unless (attempts += 1) > 1
          @client.authenticate
          retry
        else
          raise
        end
      end
    end
  end
end
