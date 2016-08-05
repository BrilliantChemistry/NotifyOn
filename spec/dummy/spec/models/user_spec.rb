require 'rails_helper'

RSpec.describe User, :type => :model do

  let(:user) { create(:user) }

  it 'has a valid factory' do
    expect(user).to be_valid
  end

  it 'should have notifications' do
    # This occurs because we have called notify_on elsewhere (e.g. Message) and
    # set a User instance as the :to option.
    expect(user.respond_to?(:notifications)).to eq(true)
  end

  it 'deletes its notifications when it is deleted' do
    user
    create(:message, :user => user)
    expect(user.notifications.count).to eq(1)
    user.destroy
    expect(NotifyOn::Notification.count).to eq(0)
  end

end
