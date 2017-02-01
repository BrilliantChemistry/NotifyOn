FactoryGirl.define do
  factory :notification, :class => 'NotifyOn::Notification' do
    recipient { create(:user) }
    sender { create(:user) }
    trigger { create(:message) }
    trait :read do
      unread { false }
    end
  end
end
