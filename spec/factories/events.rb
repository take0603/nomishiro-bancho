FactoryBot.define do
  factory :event do
    sequence(:event_name) { |n| "テストイベント#{n}" }
    explanation { "説明文" }
    date { Time.now.since(2.days) }
    deadline { Time.now.since(1.days) }
  end
end
