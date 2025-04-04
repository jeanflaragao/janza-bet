class Transaction < ApplicationRecord
  belongs_to :book

  validates :transaction_type, inclusion: { in: %w[deposit withdraw] }
  validates :date, presence: true
end
