FactoryBot.define do
  factory :bet do
    event_date { "2025-04-05" }
    game { "MyString" }
    bet { "MyText" }
    stake { "9.99" }
    odd { "9.99" }
    status { "MyString" }
    book { nil }
    tipster { nil }
    result { "9.99" }
  end
end
