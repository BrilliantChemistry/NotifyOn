require 'notify_on/engine'
require 'notify_on/configuration'
require 'notify_on/utilities'
require 'notify_on/receives_notifications'
require 'notify_on/creator'
require 'notify_on/notify_on'
require 'notify_on/bulk_config'

require 'em-http-request'
require 'hashie'
require 'pusher'

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
