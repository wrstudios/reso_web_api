module ResoWebApi
  #=RESO Web API Client
  # Main class to run requests against a RESO Web API server.
  class Client
    include Authentication
    include Connection
    include Resources

    attr_accessor :authenticator
    attr_accessor *Configuration::VALID_OPTION_KEYS

    # Creates a new client with the given configuration.
    def initialize(options = {})
      options = ResoWebApi.options.merge(options)

      Configuration::VALID_OPTION_KEYS.each do |key|
        send("#{key}=", options[key])
      end

      @authenticator = auth_mode.new(self)
    end
  end
end
