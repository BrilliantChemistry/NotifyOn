FactoryGirl.define do
  factory :post do
    author
    body { Faker::Lorem.paragraph }
  end
end
