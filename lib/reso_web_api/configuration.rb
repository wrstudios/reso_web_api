module ResoWebApi
  module Configuration
    VALID_OPTION_KEYS = [
      :api_key, :api_secret, :auth_url, :auth_scope, :auth_mode, :service_url, :timeout, :user_agent
    ]
    attr_accessor *VALID_OPTION_KEYS

    DEFAULT_API_KEY     = nil
    DEFAULT_API_SECRET  = nil
    DEFAULT_API_USER    = nil
    DEFAULT_AUTH_URL    = nil
    DEFAULT_AUTH_SCOPE  = nil
    DEFAULT_AUTH_MODE   = ResoWebApi::Authentication::TokenAuth
    DEFAULT_SERVICE_URL = nil
    DEFAULT_TIMEOUT     = 5
    DEFAULT_USER_AGENT  = "Reso Web API Ruby gem #{VERSION}"

    def configure
      yield self
    end

    def self.extended(base)
      base.reset_configuration
    end

    def options
      VALID_OPTION_KEYS.reduce({}) do |options, key|
        options.merge(key => send(key))
      end
    end

    def reset_configuration
      VALID_OPTION_KEYS.each do |key|
        send "#{key}=", const_get("ResoWebApi::Configuration::DEFAULT_#{key.upcase}")
      end
    end
  end
end
