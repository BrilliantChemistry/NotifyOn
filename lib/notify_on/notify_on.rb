class << ActiveRecord::Base

  def notify_on(action, options = {})

    include NotifyOn::Creator

    ([self] + self.descendants).each do |klass|
      klass.class_eval do
        has_many :notifications, -> { preloaded },
                 :class_name => NotifyOn::Notification, :as => :trigger,
                 :dependent => :destroy
      end
    end

    attr_accessor :skip_notifications

    method_to_s = NotifyOn::Utilities.callback_method_name(action, options)
    method_sym = method_to_s.to_sym

    if action.to_s == 'create'
      send('after_create', method_sym)
    elsif action.to_s == 'update'
      send('after_update', method_sym)
    else
      send('after_save', method_sym)
    end

    define_method(method_to_s) do
      # The action trigger needs to be create, save, or a true condition.
      return unless %w(create update save).include?(action.to_s) || send(action.to_sym)
      # An optional if condition must be missing or true.
      return unless options[:if].blank? || send(options[:if])
      # An optional unless condition must be missing or false.
      return unless options[:unless].blank? || !send(options[:unless])
      # Create the notification if we get past all our checks.
      create_notify_on_notifications(options)
    end

    private method_to_s.to_sym

  end
end
