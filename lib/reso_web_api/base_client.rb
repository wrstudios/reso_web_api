require 'faraday'

module ResoWebApi
  # Base class for Faraday-based HTTP clients
  class BaseClient
    attr_reader :endpoint, :user_agent, :adapter

    USER_AGENT = "Reso Web API Ruby Gem v#{VERSION}"
    ADAPTER    = Faraday.default_adapter

    # Create a new client instance.
    # @param endpoint [String] The base URL for requests
    # @param user_agent [String] The user agent header to send
    def initialize(endpoint:, user_agent: USER_AGENT, adapter: ADAPTER)
      @endpoint   = endpoint
      @user_agent = user_agent
      @adapter    = adapter
    end

    # Return the {Faraday::Connection} object for this client.
    # @return [Faraday::Connection] The connection object
    def connection(&block)
      @connection ||= Faraday.new(url: endpoint, headers: headers) do |conn|
        conn.request :url_encoded
        yield conn if block_given?
        # conn.options[:timeout] = self.timeout
        conn.adapter adapter
      end
    end

    # Return the headers to be sent with every request.
    # @return [Hash] The request headers.
    def headers
      {
        :user_agent => user_agent
      }
    end
  end
end
