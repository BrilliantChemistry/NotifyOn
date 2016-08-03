require 'rails_helper'

RSpec.describe Message, :type => :model do

  let(:message) { create(:message) }

  it 'has a valid factory' do
    expect(message).to be_valid
  end

  describe '#notify_on' do
    it 'creates a notification from author to sender on create' do
      expect(NotifyOn::Notification.count).to eq(0)
      message
      expect(NotifyOn::Notification.count).to eq(1)
      notification = NotifyOn::Notification.first
      expect(notification.recipient).to eq(message.user)
      expect(notification.sender).to eq(message.author)
      expect(notification.description)
        .to eq("#{message.author.email} sent you a message.")
    end
  end

end
