require 'rails_helper'

RSpec.describe User, :type => :model do

  let(:user) { create(:user) }

  describe 'self#receives_notifications' do
    it 'should be associated to notifications' do
      expect(user.respond_to?(:notifications)).to eq(true)
    end
  end

  it 'deletes its notifications when it is deleted' do
    user
    create(:message, :user => user)
    expect(user.notifications.count).to eq(1)
    user.destroy
    expect(user.notifications.count).to eq(0)
  end

end
