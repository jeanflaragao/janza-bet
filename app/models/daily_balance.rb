class DailyBalance < ApplicationRecord
  belongs_to :book
  validates :date, :balance, :book_id, presence: true
  validates :date, uniqueness: { scope: :book_id, message: "balance for this book already exists on that date" }
end
