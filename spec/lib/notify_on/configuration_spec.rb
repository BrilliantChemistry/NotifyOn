require 'rails_helper'

describe NotifyOn::Configuration do

  it 'sets the expected defaults' do
    NotifyOn.reset
    config = NotifyOn.configuration
    expect(config.pusher_app_id).to eq(nil)
    expect(config.pusher_key).to eq(nil)
    expect(config.pusher_secret).to eq(nil)
    expect(config.default_email).to eq(nil)
    expect(config.mailer_class).to eq('NotifyOn::NotificationMailer')
  end

  it 'can be overridden' do
    NotifyOn.configure do |config|
      config.pusher_app_id = 'my_app_id'
      config.pusher_key = 'my_key'
      config.pusher_secret = 'my_secret'
      config.default_email = 'noreply@example.com'
      config.mailer_class = 'NotificationMailer'
    end
    config = NotifyOn.configuration
    expect(config.pusher_app_id).to eq('my_app_id')
    expect(config.pusher_key).to eq('my_key')
    expect(config.pusher_secret).to eq('my_secret')
    expect(config.default_email).to eq('noreply@example.com')
    expect(config.mailer_class).to eq('NotificationMailer')
  end

end
