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

end
