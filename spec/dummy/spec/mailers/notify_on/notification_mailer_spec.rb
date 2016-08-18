require "rails_helper"

RSpec.describe NotifyOn::NotificationMailer, :type => :mailer do

  describe 'message notifications on create' do
    it 'can be overridden with a customized view' do
      message = create(:message)
      n = first_notification
      mail = NotifyOn::NotificationMailer.notify(n.id, 'new_message')
      expect(mail.to).to eq([message.user.email])
      expect(mail.from).to eq([message.author.email])
      expect(mail.body.encoded)
        .to include("#{message.author.to_s} sent you a message:")
    end
    it 'will use a custom mailer if configured to do so' do
      # Note: We're setting this on the fly instead of overriding throughout the
      # dummy app.
      NotifyOn.configure { |config| config.mailer_class = 'NotificationMailer' }
      message = create(:message)
      mail = emails[0]
      # We only change one iteme in this mailer -- just enough to show us we're
      # using the correct one.
      expect(mail.from).to eq(['admin@bobross.com'])
      NotifyOn.configure do |config|
        config.mailer_class = 'NotifyOn::NotificationMailer'
      end
    end
  end

end
