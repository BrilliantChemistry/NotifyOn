require 'rails_helper'

RSpec.describe Message, :type => :model do

  let(:message) { create(:message) }

  it 'has a valid factory' do
    expect(message).to be_valid
  end

  describe '#notify_on' do
    it 'creates a notification from author to sender on create' do
      [notification_count, total_emails].each { |n| expect(n).to eq(0) }
      message
      [notification_count, total_emails].each { |n| expect(n).to eq(1) }
      expect(first_notification.recipient).to eq(message.user)
      expect(first_notification.sender).to eq(message.author)
      expect(first_notification.description)
        .to eq("#{message.author.email} sent you a message.")
    end
    it 'deletes its notifications when it is deleted' do
      message
      expect(message.notifications.count).to eq(1)
      message.destroy
      expect(notification_count).to eq(0)
    end
  end

end
