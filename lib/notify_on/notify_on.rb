class << ActiveRecord::Base

  def notify_on(action, options = {})

    include NotifyOn::Helpers

    options[:to].to_s.classify.constantize.class_eval do
      has_many :notifications, -> { preloaded },
               :class_name => NotifyOn::Notification, :as => :recipient
    end

    case action.to_sym
    when :create

      after_create :"notify_#{options[:to]}_on_create"

      define_method "notify_#{options[:to]}_on_create" do
        notification = NotifyOn::Notification.create(
          :recipient => send(options[:to].to_s),
          :sender => send(options[:from].to_s),
          :trigger => self,
          :description => notify_on_description(options[:message]),
          :link => notify_on_link(options[:link])
        )

        notify_on_send_email(notification, options[:template]) if options[:email]
      end

    end

  end

end
