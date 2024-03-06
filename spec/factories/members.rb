FactoryBot.define do
  factory :member do
    sequence(:member_name) { |n| "テストメンバー#{n}" }
  end
end
