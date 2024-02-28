FactoryBot.define do
  factory :payment do
    sequence(:payment_name) { |n| "支払表#{n}" } 
    amount { 10000 } 
  end
end
