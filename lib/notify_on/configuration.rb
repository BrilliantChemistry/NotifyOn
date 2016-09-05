module NotifyOn
  class Configuration

    attr_accessor \
      :default_email,
      :default_pusher_channel,
      :default_pusher_event,
      :deliver_mail,
      :mailer_class,
      :pusher_app_id,
      :pusher_key,
      :pusher_secret,
      :use_pusher_by_default

    def initialize
      @deliver_mail = :now
      @mailer_class = 'NotifyOn::NotificationMailer'
      @use_pusher_by_default = false
    end

  end
end
