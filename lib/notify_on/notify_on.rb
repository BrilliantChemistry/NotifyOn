class << ActiveRecord::Base

  def notify_on(action, options = {})

    include NotifyOn::Helpers

    has_many :notifications, -> { preloaded },
             :class_name => NotifyOn::Notification, :as => :trigger,
             :dependent => :destroy

    notify_on_to = if reflect_on_association(options[:to]).nil?
      options[:to_class_name].to_s
    else
      reflect_on_association(options[:to]).class_name
    end

    notify_on_to.constantize.class_eval do
      has_many :notifications, -> { preloaded },
               :class_name => NotifyOn::Notification, :as => :recipient,
               :dependent => :destroy
    end

    case action.to_sym
    when :create

      after_create :"notify_#{options[:to]}_on_create"

      define_method "notify_#{options[:to]}_on_create" do
        send(options[:to].to_s).to_a.each do |recipient|
          notification = NotifyOn::Notification.create(
            :recipient => recipient,
            :sender => options[:from].blank? ? nil : send(options[:from].to_s),
            :trigger => self,
            :description => notify_on_string_conversion(options[:message]),
            :link => notify_on_link(options[:link]),
            :use_default_email => options[:use_default_email] || false
          )

          if options[:email]
            notify_on_send_email(notification, options[:template])
          end

          if options[:pusher]
            notify_on_trigger_pusher(options[:pusher][:channel],
                                     options[:pusher][:event],
                                     :notification => notification.to_json,
                                     :trigger => self.to_json)
          end
        end
      end

    end

  end

end
