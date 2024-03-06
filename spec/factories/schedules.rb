FactoryBot.define do
  factory :schedule do
    schedule_date { Time.now.since(1.days) }
  end
end
