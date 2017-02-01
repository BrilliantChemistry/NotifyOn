require 'rails_helper'

RSpec.describe Message, :type => :model do

  let(:message) { create(:message) }

  context 'creates a notification that' do
    before(:each) do
      @message = message
      @notification = first_notification
    end
    it 'is the only notification' do
      [notification_count, email_count].each { |n| expect(n).to eq(1) }
    end
    it 'gets deleted when it is deleted' do
      message.destroy
      expect(notification_count).to eq(0)
    end
    it 'can be skipped by using "skip_notifications"' do
      expect { create(:message, :skip_notifications => true) }
        .to change { notification_count }.by(0)
    end
    it 'is to the message "user"' do
      expect(@notification.recipient).to eq(message.user)
    end
    it 'is from the message author' do
      expect(@notification.sender).to eq(message.author)
    end
    it 'interpolates a description' do
      msg = "#{message.author.email} sent you a message."
      expect(@notification.description).to eq(msg)
    end
    it 'interpolates the link' do
      expect(@notification.link).to eq("/messages/#{@message.id}")
    end
    it 'is accessible via an association' do
      expect(@message.respond_to?(:notifications)).to eq(true)
      expect(@message.notifications.to_a).to match_array([@notification])
    end
    context 'sends an email that' do
      before(:each) { @email = emails[0] }
      it 'is sent from the default address' do
        # This is set in the initializer.
        expect(@email.from).to eq(['noreply@example.com'])
      end
      it 'is sent to the notification recipient' do
        expect(@email.to).to eq([@notification.recipient.email])
      end
      it 'has a fallback subject that matches the description' do
        subject = "#{message.author.email} sent you a message."
        expect(@email.subject).to eq(subject)
      end
      it 'uses the default template' do
        expect(@email.body.encoded).to include('You have a new notification:')
        expect(@email.body.encoded).to include(@notification.description)
      end
    end
  end

end
