require 'json'
require 'logger'
require 'odata4'

require 'reso_web_api/errors'
require 'reso_web_api/authentication'
require 'reso_web_api/configuration'
require 'reso_web_api/connection'
require 'reso_web_api/resources'
require 'reso_web_api/client'
require 'reso_web_api/version'

module ResoWebApi
  extend Configuration

  def self.client(options = {})
    Thread.current[:reso_web_api_client] ||= ResoWebApi::Client.new(options)
  end

  def self.reset
    reset_configuration
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
