module NotifyOn
  module EmailSupport

    def send_email!
      return false unless can_send_email?
      NotifyOn.configuration.mailer_class.constantize
              .notify(id, email_template)
              .send("deliver_#{email_delivery_timing}")
    end

    def email_template
      return nil unless email_config?
      opts.email.template
    end

    def email_from
      return NotifyOn.configuration.default_email if use_default_email?
      return email_config.from if email_config? && email_config.from?
      sender.email
    end

    def email_subject
      return email_config.subject if email_config? && email_config.subject?
      description
    end

    def should_save_email_id?
      email_config? && email_config.save_id?
    end

    private

      def email_delivery_timing
        return email_config.deliver if email_config? && email_config.deliver?
        NotifyOn.configuration.deliver_mail.to_s
      end

      def email_config
        opts.email
      end

      def email_enabled?
        opts.email?
      end

      def email_disabled?
        !email_enabled?
      end

      def email_config?
        email_enabled? && email_config.respond_to?(:[])
      end

      def can_send_email?
        return false if email_disabled?
        return true unless email_config.unless.present?
        begin
          !trigger.send(email_config.unless.to_s)
        rescue
          !send(email_config.unless.to_s)
        end
      end

      def use_default_email?
        return opts.email.default_from if email_config? &&
                                          !email_config.default_from.nil?
        NotifyOn.configuration.use_default_email
      end

  end
end
