module NotifyOn
  class Configuration

    attr_accessor :default_email, :mailer_class, :pusher_app_id, :pusher_key,
                  :pusher_secret, :default_pusher_channel,
                  :default_pusher_event, :use_default_email

    def initialize
      @mailer_class = 'NotifyOn::NotificationMailer'
      @use_default_email = false
    end

  end
end
