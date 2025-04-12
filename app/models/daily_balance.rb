class DailyBalance < ApplicationRecord
  belongs_to :book
  validates :date, :balance, :book_id, presence: true
  validates :date, uniqueness: { scope: :book_id, message: "balance for this book already exists on that date" }

  def self.generate_for_date(date)
    date = Date.parse(date.to_s)

    # Pega todos os livros
    Book.find_each do |book|
      # Cria um DailyBalance só se ainda não existir um para esse book e data
      find_or_create_by(book: book, date: date)
    end
  end
end
