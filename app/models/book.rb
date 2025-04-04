class Book < ApplicationRecord
  belongs_to :user 
  validates :owner, presence: true
  validates :name, presence: true
  has_many :transactions, dependent: :destroy

  before_validation :set_description

  def balance
    transactions.sum { |t| t.transaction_type == "withdraw" ? -t.amount : t.amount }
  end
  
  private

  def set_description
    self.description = "#{owner}-#{name}" if description.blank?
  end
end
