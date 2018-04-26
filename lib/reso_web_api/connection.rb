require 'faraday'

module ResoWebApi
  module Connection
    def connection
      options = { :headers => headers }

      Faraday.new(options) do |conn|
        conn.request :url_encoded
        conn.options[:timeout] = self.timeout
        conn.adapter Faraday.default_adapter
      end
    end

    def headers
      {
        :accept     => 'application/json',
        :user_agent => Configuration::DEFAULT_USER_AGENT
      }
    end
  end
end
