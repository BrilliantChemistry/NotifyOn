require 'notify_on/engine'
require 'notify_on/configuration'
require 'notify_on/helpers'
require 'notify_on/notify_on'

require 'pusher'
require 'em-http-request'

module NotifyOn
  class << self
    attr_writer :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.reset
    @configuration = Configuration.new
  end

  def self.configure
    yield(configuration)
  end
end
