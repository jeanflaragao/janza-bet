FactoryBot.define do
  factory :transaction do
    book { nil }
    transaction_type { "MyString" }
    date { "2025-04-03 10:15:05" }
  end
end
