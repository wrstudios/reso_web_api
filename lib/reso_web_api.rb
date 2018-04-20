require 'logger'

require 'reso_web_api/client'
require 'reso_web_api/version'

module ResoWebApi
  def self.client(options = {})
    Thread.current[:reso_web_api_client] ||= ResoWebApi::Client.new(options)
  end

  def self.reset
    Thread.current[:reso_web_api_client] = nil
  end

  def self.logger
    if @logger.nil?
      @logger = Logger.new(STDOUT)
      @logger.level = Logger::INFO
    end
    @logger
  end

  def self.logger=(logger)
    @logger = logger
  end
end
