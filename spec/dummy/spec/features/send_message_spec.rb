require 'rails_helper'

feature 'Send Message' do

  scenario 'Creates a notification for the other user' do
    me = create(:user)
    other_user = create(:user)

    sign_in_as me
    visit new_message_path

    expect(NotifyOn::Notification.count).to eq(0)

    select other_user.email, :from => 'message_user_id'
    fill_in 'message_content', :with => Faker::Lorem.paragraph
    click_button 'Create Message'

    expect(NotifyOn::Notification.count).to eq(1)
    notification = NotifyOn::Notification.first
    expect(notification.recipient).to eq(other_user)
    expect(notification.sender).to eq(me)
    expect(notification.description).to eq("#{me.email} sent you a message.")
  end

end
