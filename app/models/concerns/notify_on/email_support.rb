module NotifyOn
  module EmailSupport

    def send_email!
      return false unless can_send_email?
      begin
        NotifyOn.configuration.mailer_class.constantize
              .notify(id, email_template, email_attachments)
              .send("deliver_#{email_delivery_timing}")
      rescue Exception => e
        Rails.logger.error("Unable to send notification email: #{e}")
      end
    end

    def email_template
      return nil unless email_config?
      email_config.template || 'notify'
    end

    def email_from
      convert_string(email_from_raw)
    end

    def email_subject
      return email_config.subject if email_config? && email_config.subject?
      description
    end

    def should_save_email_id?
      email_config? && email_config.save_id?
    end

    def email_attachments
      attachments = []
      return attachments unless email_config? && email_config.attachments?
      email_config.attachments.each do |name, renderer|
        next unless trigger.send(renderer.if) if renderer.try(:if?)
        filename = begin
          trigger.send(name)
        rescue => e
          name
        end
        begin
          file = if renderer.is_a?(Symbol)
            trigger.send(renderer)
          else
            trigger.send(renderer.file)
          end
        rescue => e
          raise "Could not create file: #{filename}\n#{e}"
        end
        attachments << { :name => filename, :file => file }
      end
      attachments
    end

    private

      def email_delivery_timing
        return email_config.deliver if email_config? && email_config.deliver?
        NotifyOn.configuration.deliver_mail.to_s
      end

      def email_config
        return nil unless opts.email
        opts.email.is_a?(Hashie::Mash) ? opts.email : Hashie::Mash.new
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
        return true unless email_config.unless?
        begin
          !trigger.send(email_config.unless)
        rescue
          !send(email_config.unless)
        end
      end

      def use_default_email?
        email_disabled? || !email_config.from?
      end

      def email_from_raw
        return NotifyOn.configuration.default_email if use_default_email?
        email_config.from
      end

  end
end
