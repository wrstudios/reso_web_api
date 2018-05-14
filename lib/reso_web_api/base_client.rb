require 'faraday'
require 'dry-initializer'

module ResoWebApi
  # Base class for Faraday-based HTTP clients
  class BaseClient
    extend Dry::Initializer

    option :endpoint
    option :user_agent, default: proc { USER_AGENT }
    option :adapter, default: proc { Faraday::default_adapter }
    option :logger, default: proc { ResoWebApi.logger }

    USER_AGENT = "Reso Web API Ruby Gem v#{VERSION}"

    # Return the {Faraday::Connection} object for this client.
    # Yields the connection object being constructed (for customzing middleware).
    # @return [Faraday::Connection] The connection object
    def connection(&block)
      @connection ||= Faraday.new(url: endpoint, headers: headers) do |conn|
        conn.request :url_encoded
        conn.response :logger, logger
        yield conn if block_given?
        conn.adapter adapter unless conn.builder.send(:adapter_set?)
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
