require "rails_helper"

RSpec.describe NotifyOn::NotificationMailer, :type => :mailer do

  describe 'message notifications on create' do
    it 'can be overridden with a customized view' do
      message = create(:message)
      notification = NotifyOn::Notification.first
      mail = NotifyOn::NotificationMailer.notify(notification.id, 'new_message')
      expect(mail.to).to eq([message.user.email])
      expect(mail.from).to eq([message.author.email])
      expect(mail.body.encoded)
        .to include("#{message.author.to_s} sent you a message:")
    end
  end

end
