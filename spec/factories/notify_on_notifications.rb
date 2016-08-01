FactoryGirl.define do
  factory :notify_on_notification, class: 'NotifyOn::Notification' do
    recipient_id 1
    sender_id 1
    unread false
    trigger_id 1
    trigger_type "MyString"
  end
end
