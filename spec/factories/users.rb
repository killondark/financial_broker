FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "person#{n}@example.com" }
    name { 'Default name' }

    trait :with_orders do
      after(:create) { |user| create(:order, user: user) }
    end

    trait :with_account do
      after(:create) { |user| create(:account, user: user) }
    end
  end
end
