module NotifyOn
  class Configuration

    attr_accessor \
      :default_email,
      :default_pusher_channel,
      :default_pusher_event,
      :mailer_class,
      :pusher_app_id,
      :pusher_key,
      :pusher_secret,
      :use_default_email

    def initialize
      @mailer_class = 'NotifyOn::NotificationMailer'
      @use_default_email = false
    end

  end
end
