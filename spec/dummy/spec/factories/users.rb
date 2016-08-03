FactoryGirl.define do
  factory :user, :aliases => [:author] do
    email { Faker::Internet.email }
    password 'password'
  end
end
