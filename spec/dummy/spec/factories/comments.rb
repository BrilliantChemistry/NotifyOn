FactoryGirl.define do
  factory :comment do
    user
    post
    body { Faker::Lorem.paragraph }
  end
end
