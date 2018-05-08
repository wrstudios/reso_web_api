module ResoWebApi
  class Error < StandardError; end

  class NetworkError < Error
    attr_reader :response

    def initialize(options = {})
      # Support the standard initializer for errors
      opts = options.is_a?(Hash) ? options : { message: options.to_s }
      @response = opts[:response]
      super(opts[:message])
    end

    def status
      response && response.status
    end
  end

  module Errors
    class AccessDenied < NetworkError; end
  end
end
