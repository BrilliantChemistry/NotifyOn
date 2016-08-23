require 'rails_helper'

module NotifyOn
  RSpec.describe Notification, :type => :model do

    before(:each) do
      @message = create(:message)
      @notification = NotifyOn::Notification.first
    end

    describe '#read!' do
      it 'sets unread to false' do
        expect(@notification.unread?).to eq(true)
        @notification.read!
        expect(@notification.reload.unread?).to eq(false)
      end
    end

    describe '#link' do
      it 'resolves and caches its link and returns the cached version' do
        expect(@notification.link_cached).to eq("/messages/#{@message.id}")
        expect(@notification.link).to eq(@notification.link_cached)
      end
    end

    describe '#description' do
      it 'resolves and caches its description and returns the cached version' do
        expect(@notification.description_cached)
          .to eq("#{@message.author.email} sent you a message.")
        expect(@notification.description)
          .to eq(@notification.description_cached)
      end
    end

    # ---------------------------------------- Pusher

    describe '#pusher_channel_name' do
      it 'interpolates the id' do
        # "send" is used because "pusher_channel_name" is a private method.
        expect(@notification.send(:pusher_channel_name))
          .to eq("presence-message-#{@notification.id}")
      end
    end

    describe '#pusher_event_name' do
      it 'interpolates the id' do
        expect(@notification.send(:pusher_event_name))
          .to eq("new-message-#{@notification.id}")
      end
    end

    describe '#pusher_attrs' do
      it 'contains the notification, trigger, and optional data' do
        attrs = @notification.send(:pusher_attrs)
        expect(attrs[:notification]).to eq(@notification.to_json)
        expect(attrs[:trigger]).to eq(@message.to_json)
        expect(attrs[:data]).to eq({ :is_chat => true })
      end
    end

    # ---------------------------------------- Email

    describe '#email_template' do
      it 'returns the name of the specified template' do
        expect(@notification.send(:email_template)).to eq('new_message')
      end
    end

    describe '#set_default_from' do
      it 'sets "use_default_email" automatically when not set' do
        expect(@notification.use_default_email).to eq(false)
      end
    end

    describe '#can_send_email?' do
      it 'will use a method on the trigger to conditionally send email' do
        expect(@notification.can_send_email?).to eq(true)
        @message.update_columns(:content => "[DELAYED] #{@message.content}")
        @notification.trigger.reload
        expect(@notification.can_send_email?).to eq(false)
      end
    end

  end
end
