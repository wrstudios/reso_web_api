module ResoWebApi
  class ClientError < StandardError
    attr_reader :code, :status, :details, :request_path, :errors
    def initialize (options = {})
      # Support the standard initializer for errors
      opts = options.is_a?(Hash) ? options : {:message => options.to_s}
      @code = opts[:code]
      @status = opts[:status]
      @details = opts[:details]
      @request_path = opts[:request_path]
      @errors = opts[:errors]
      super(opts[:message])
    end

  end
  class NotFound < ClientError; end
  class PermissionDenied < ClientError; end
  class NotAllowed < ClientError; end
  class BadResourceRequest < ClientError; end
end
