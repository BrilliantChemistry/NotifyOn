class << ActiveRecord::Base

  def notify_on(action, options = {})

    case action.to_sym
    when :create

      after_create :"notify_#{options[:to]}"

      define_method "notify_#{options[:to]}" do
        puts send(options[:to].to_s).to_s
        puts send(options[:from].to_s).to_s
        puts author_email
        puts options[:message].gsub(/{([\w\_]+)}/, "HI")
        puts options[:message].gsub(/{([\w\_]+)}/, send($1))
        NotifyOn::Notification.create(
          :recipient => send(options[:to].to_s),
          :sender => send(options[:from].to_s),
          :trigger => self,
          :description => options[:message].gsub(/{([\w\_]+)}/, send($1))
        )
      end

    end

  end

  # define_method "geocode_if_address" do

end
