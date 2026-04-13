FactoryBot.define do
  factory :account do
    user { association :user }
    balance { 0.0 }
  end
end
