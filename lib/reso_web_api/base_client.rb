require 'faraday'

module ResoWebApi
  # Base class for HTTP clients
  class BaseClient
    USER_AGENT = "Reso Web API Ruby Gem v#{VERSION}"

    attr_reader :endpoint, :user_agent, :adapter

    # Create a new client instance.
    # @param endpoint [String] The base URL for requests
    # @param user_agent [String] The user agent header to send
    def initialize(endpoint:, user_agent: USER_AGENT, adapter: Faraday.default_adapter)
      @endpoint   = endpoint
      @user_agent = user_agent
      @adapter    = adapter
    end

    def connection
      @connection ||= Faraday.new(url: endpoint, headers: headers) do |conn|
        conn.request :url_encoded
        # conn.options[:timeout] = self.timeout
        conn.adapter adapter
      end
    end

    def headers
      {
        :user_agent => user_agent
      }
    end
  end
end
