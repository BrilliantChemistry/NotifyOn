FactoryGirl.define do
  factory :post do
    author { create(:user) }
    body { Faker::Lorem.paragraph }
  end
end
