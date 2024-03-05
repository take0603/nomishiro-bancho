FactoryBot.define do
  factory :payment_detail do
    sequence(:participant) { |n| "参加者#{n}" }
    fee { 0 }
    is_paid { false }
  end
end
