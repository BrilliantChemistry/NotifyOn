require 'rails_helper'

module NotifyOn
  RSpec.describe Notification, :type => :model do

    before(:each) do
      @message = create(:message)
      @n = first_notification
    end

    describe 'self#mark_read_for, self#unread' do
      it 'will mark read by a single recipient and trigger' do
        NotifyOn::Notification.mark_read_for(@message.user, @message)
        expect(@n.reload.unread?).to eq(false)
      end
      it 'will mark read those matching an array of recipients and triggers' do
        Message.destroy_all
        messages = create_list(:message, 10)
        read_msgs = messages.first(5)
        unread_msgs = messages - read_msgs
        recipients = read_msgs.collect(&:user)
        NotifyOn::Notification.mark_read_for(recipients, read_msgs)
        read_msgs.each { |m| expect(m.notifications[0].unread?).to eq(false) }
        unread_msgs.each { |m| expect(m.notifications[0].unread?).to eq(true) }
        unread = unread_msgs.collect(&:notifications).flatten
        expect(NotifyOn::Notification.unread.to_a).to match_array(unread)
      end
    end

    describe '#read?, #read!' do
      it 'sets unread to false' do
        expect(@n.unread?).to eq(true)
        expect(@n.read?).to eq(false)
        @n.read!
        expect(@n.reload.unread?).to eq(false)
        expect(@n.read?).to eq(true)
      end
    end

    describe '#link' do
      it 'caches an interpolated link and returns it' do
        expect(@n.link_cached).to eq("/messages/#{@message.id}")
        expect(@n.link).to eq(@n.link_cached)
      end
      it 'falls back to converting the raw link when not cached' do
        @n.update_columns(:link_cached => nil)
        expect(@n.reload.link_cached).to eq(nil)
        expect(@n.link).to eq("/messages/#{@message.id}")
      end
      it 'returns nil when both raw and cached are missing' do
        @n.update_columns(:link_cached => nil, :link_raw => nil)
        expect(@n.reload.link).to eq(nil)
      end
    end

    describe '#description' do
      before(:each) { @desc = "#{@message.author.email} sent you a message." }
      it 'caches an interpolated description and returns it' do
        expect(@n.description_cached).to eq(@desc)
        expect(@n.description).to eq(@n.description_cached)
      end
      it 'falls back to converting the raw description when not cached' do
        @n.update_columns(:description_cached => nil)
        expect(@n.reload.description_cached).to eq(nil)
        expect(@n.description).to eq(@desc)
      end
      it 'returns nil when both raw and cached are missing' do
        @n.update_columns(:description_cached => nil, :description_raw => nil)
        expect(@n.reload.description).to eq(nil)
      end
    end

    describe '#opts' do
      it 'uses method_missing to convert "options" to Hashie::Mash' do
        expect(@n.opts).to eq(Hashie::Mash.new(@n.options))
      end
      it 'returns a blank Mash when options is nil' do
        @n.update_columns(:options => nil)
        expect(@n.opts).to eq(Hashie::Mash.new)
      end
    end

  end
end
