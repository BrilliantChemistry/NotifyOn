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

    # ---------------------------------------- String Interpolation

    describe 'StringInterpolation' do
      let(:n) { build(:notification) }
      describe '#convert_string' do
        it 'returns nil when given nil' do
          expect(n.send(:convert_string, nil)).to eq(nil)
        end
        it 'returns the string if given as plain text' do
          str = Faker::Lorem.sentence
          expect(n.send(:convert_string, str)).to eq(str)
        end
        it 'interpolates the environment' do
          str = Faker::Lorem.sentence
          expect(n.send(:convert_string, "#{str} {:env}")).to eq("#{str} test")
        end
        it "interpolates the recipient's id" do
          input = "#{str = Faker::Lorem.sentence} {:recipient_id}"
          output = "#{str} #{n.recipient.id}"
          expect(n.send(:convert_string, input)).to eq(output)
        end
        it 'interpolates methods on the trigger' do
          input = 'Message #{id}: {content}'
          output = "Message ##{n.trigger.id}: #{n.trigger.content}"
          expect(n.send(:convert_string, input)).to eq(output)
        end
        it 'falls back to notification methods when undefined on trigger' do
          input = 'Message #{id}: {description}'
          output = "Message ##{n.trigger.id}: #{n.description}"
          expect(n.send(:convert_string, input)).to eq(output)
        end
        it 'throws an error when method does not exist on trigger or self' do
          input = '{blah_blah}'
          expect { n.send(:convert_string, input) }.to raise_error(NoMethodError)
        end
        it 'supports daisy-chaining methods' do
          input = 'Message From: {author.email}'
          output = "Message From: #{n.trigger.author.email}"
          expect(n.send(:convert_string, input)).to eq(output)
        end
      end
      describe '#convert_link' do
        it 'returns nil when given nil' do
          expect(n.send(:convert_link, nil)).to eq(nil)
        end
        it 'resolves multiple arguments' do
          input = 'user_message_path(:author, :self)'
          output = "/users/#{n.trigger.author.id}/messages/#{n.trigger.id}"
          expect(n.send(:convert_link, input)).to eq(output)
        end
        it 'leaves argument strings alone' do
          input = 'user_message_path(author, :self)'
          output = "/users/author/messages/#{n.trigger.id}"
          expect(n.send(:convert_link, input)).to eq(output)
        end
      end
    end

    # ---------------------------------------- Pusher Support

    describe 'PusherSupport' do
      let(:n) { create(:notification) }

      context 'can not push' do
        describe '#can_push?' do
          it 'returns false' do
            NotifyOn.configure { |config| config.use_pusher_by_default = false }
            expect(n.send(:can_push?)).to eq(false)
          end
          it 'would return true if we change the default config' do
            NotifyOn.configure { |config| config.use_pusher_by_default = true }
            expect(n.send(:can_push?)).to eq(true)
            NotifyOn.configure { |config| config.use_pusher_by_default = false }
          end
        end
        describe '#pusher_channel_name' do
          it 'returns nil' do
            expect(n.pusher_channel_name).to eq(nil)
          end
        end
        describe '#pusher_event_name' do
          it 'returns nil' do
            expect(n.pusher_event_name).to eq(nil)
          end
        end
        describe '#pusher_attrs' do
          it 'returns nil' do
            expect(n.pusher_attrs).to eq(nil)
          end
        end
      end

      context 'can push' do
        before(:each) do
          opts = n.options
          opts[:pusher] = {
            :channel => 'presence-{:env}-message-{id}',
            :event => :new_message
          }
          n.options = opts
          n.save!
        end
        describe '#pusher_channel_name' do
          it 'uses string interpolation to build channel name' do
            exp_channel_name = "presence-test-message-#{n.trigger.id}"
            expect(n.pusher_channel_name).to eq(exp_channel_name)
          end
        end
        describe '#pusher_event_name' do
          it 'uses the specified option' do
            expect(n.pusher_event_name).to eq('new_message')
          end
        end
        describe '#pusher_attrs' do
          it 'sets up default attributes' do
            attrs = {
              :notification => n.to_json,
              :trigger => n.trigger.to_json,
              :data => nil
            }
            expect(n.pusher_attrs).to eq(attrs)
          end
          it 'will define custom variables' do
            n.options[:pusher][:data] = { :is_chat => true }
            n.save!
            attrs = {
              :notification => n.to_json,
              :trigger => n.trigger.to_json,
              :data => { :is_chat => true }
            }
            expect(n.pusher_attrs).to eq(attrs)
          end
        end
      end

    end

    # ---------------------------------------- Email Support

    describe 'EmailSupport' do
      let(:n) { build(:notification) }

      def update_email_config(config)
        n.options[:email] = config
        n.save!
      end

      describe '#email_config, #email_enabled?, #email_disabled?, #email_config?' do
        it 'is disabled if no config' do
          update_email_config(nil)
          expect(n.send(:email_config)).to eq(nil)
          expect(n.send(:email_config?)).to eq(false)
          expect(n.send(:email_enabled?)).to eq(false)
          expect(n.send(:email_disabled?)).to eq(true)
        end
        it 'is enabled if only set to "true"' do
          update_email_config(true)
          expect(n.send(:email_config)).to eq(Hashie::Mash.new)
          expect(n.send(:email_config?)).to eq(true)
          expect(n.send(:email_enabled?)).to eq(true)
          expect(n.send(:email_disabled?)).to eq(false)
        end
        it 'is enabled if given arguments' do
          update_email_config(:template => 'new_message')
          expect(n.send(:email_config))
            .to eq(Hashie::Mash.new(:template => 'new_message'))
          expect(n.send(:email_config?)).to eq(true)
          expect(n.send(:email_enabled?)).to eq(true)
          expect(n.send(:email_disabled?)).to eq(false)
        end
      end

      describe '#can_send_email?' do
        it 'returns false if email is disabled' do
          update_email_config(false)
          expect(n.send(:can_send_email?)).to eq(false)
        end
        it 'returns true if email enabled and "unless" not specified' do
          update_email_config(true)
          expect(n.send(:can_send_email?)).to eq(true)
        end
        it 'returns false if "unless" resolves to true' do
          n.define_singleton_method(:unless_method?) do
            true
          end
          update_email_config(:unless => :unless_method?)
          expect(n.send(:can_send_email?)).to eq(false)
        end
        it 'returns true if "unless" resolves to false' do
          n.define_singleton_method(:unless_method?) do
            false
          end
          update_email_config(:unless => :unless_method?)
          expect(n.send(:can_send_email?)).to eq(true)
        end
      end

      describe '#email_template' do
        it 'returns nil if there is no config' do
          update_email_config(nil)
          expect(n.email_template).to eq(nil)
        end
        it 'returns "notify" if email config exists, but template is missing' do
          update_email_config(true)
          expect(n.email_template).to eq('notify')
        end
        it 'returns the template if specified' do
          update_email_config({ :template => 'new_message' })
          expect(n.email_template).to eq('new_message')
        end
      end

      describe '#email_from, #email_from_raw' do
        it 'returns the default address if email is disabled' do
          update_email_config(nil)
          expect(n.email_from).to eq('NotifyOn <noreply@example.com>')
        end
        it 'returns the address if specified' do
          update_email_config(:from => 'Paul McCartney <paul@thebeatles.com>')
          expect(n.email_from).to eq('Paul McCartney <paul@thebeatles.com>')
        end
      end

      describe '#email_subject' do
        it 'falls back to the description' do
          update_email_config(nil)
          expect(n.email_subject).to eq(n.description)
        end
        it 'returns the subject if specified' do
          update_email_config(:subject => (subj = Faker::Lorem.sentence))
          expect(n.email_subject).to eq(subj)
        end
      end
    end

  end
end
