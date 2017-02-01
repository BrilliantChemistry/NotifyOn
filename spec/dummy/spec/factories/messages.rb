FactoryGirl.define do
  factory :message do
    user
    author
    content { Faker::Lorem.paragraph }
  end
end
