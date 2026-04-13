FactoryBot.define do
  factory :order do
    description { 'Default order description' }
    user { association :user }

    trait :status_completed do
      status { :completed }
    end

    trait :status_cancelled do
      status { :cancelled }
    end
  end
end
