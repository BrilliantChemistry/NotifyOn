FactoryGirl.define do
  factory :comment do
    user
    body { Faker::Lorem.paragraph }
  end
end
