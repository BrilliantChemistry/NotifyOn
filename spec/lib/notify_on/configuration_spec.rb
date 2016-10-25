require 'rails_helper'

describe NotifyOn::Configuration do

  # Reset the configuration to what the app was using after each spec here.
  after(:each) do
    NotifyOn.configure do |config|
      config.default_email = 'NotifyOn <noreply@example.com>'
      config.pusher_app_id = 'my_app_id'
      config.pusher_key = 'my_key'
      config.pusher_secret = 'my_secret'
    end
  end

  it 'sets the expected defaults' do
    NotifyOn.reset
    config = NotifyOn.configuration
    expect(config.default_email).to eq(nil)
    expect(config.default_pusher_channel).to eq(nil)
    expect(config.default_pusher_event).to eq(nil)
    expect(config.deliver_mail).to eq(:now)
    expect(config.mailer_class).to eq('NotifyOn::NotificationMailer')
    expect(config.pusher_app_id).to eq(nil)
    expect(config.pusher_key).to eq(nil)
    expect(config.pusher_secret).to eq(nil)
    expect(config.use_pusher_by_default).to eq(false)
  end

  it 'can be overridden' do
    NotifyOn.configure do |config|
      config.default_email = 'noreply@example.com'
      config.default_pusher_channel = 'presence-message-{id}'
      config.default_pusher_event = 'new_message'
      config.deliver_mail = :later
      config.mailer_class = 'NotificationMailer'
      config.pusher_app_id = 'my_app_id'
      config.pusher_key = 'my_key'
      config.pusher_secret = 'my_secret'
      config.use_pusher_by_default = true
    end
    config = NotifyOn.configuration
    expect(config.default_email).to eq('noreply@example.com')
    expect(config.default_pusher_channel).to eq('presence-message-{id}')
    expect(config.default_pusher_event).to eq('new_message')
    expect(config.deliver_mail).to eq(:later)
    expect(config.mailer_class).to eq('NotificationMailer')
    expect(config.pusher_app_id).to eq('my_app_id')
    expect(config.pusher_key).to eq('my_key')
    expect(config.pusher_secret).to eq('my_secret')
    expect(config.use_pusher_by_default).to eq(true)
  end

end
