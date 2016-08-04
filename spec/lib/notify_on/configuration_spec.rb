require 'rails_helper'

describe NotifyOn::Configuration do

  it 'sets the expected defaults' do
    NotifyOn.reset
    expect(NotifyOn.configuration.pusher_app_id).to eq(nil)
    expect(NotifyOn.configuration.pusher_key).to eq(nil)
    expect(NotifyOn.configuration.pusher_secret).to eq(nil)
  end

  it 'can be overridden' do
    NotifyOn.configure do |config|
      config.pusher_app_id = 'my_app_id'
      config.pusher_key = 'my_key'
      config.pusher_secret = 'my_secret'
    end
    expect(NotifyOn.configuration.pusher_app_id).to eq('my_app_id')
    expect(NotifyOn.configuration.pusher_key).to eq('my_key')
    expect(NotifyOn.configuration.pusher_secret).to eq('my_secret')
  end

end
