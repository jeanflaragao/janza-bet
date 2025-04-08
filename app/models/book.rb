class Book < ApplicationRecord
  belongs_to :user 
  validates :owner, presence: true
  validates :name, presence: true
  has_many :transactions, dependent: :destroy
  has_many :daily_balances, dependent: :destroy

  before_validation :set_description

  def total_deposit
    daily_balances.where("balance > 0").sum(:balance)
  end
  
  def total_withdraw
    daily_balances.where("balance < 0").sum(:balance)
  end
  
  def last_daily_balance
    daily_balances.order(date: :desc).limit(1).pluck(:balance).first
  end
  
  def balance
    transactions.sum { |t| t.transaction_type == "withdraw" ? -t.amount : t.amount }
  end
  
  private

  def set_description
    self.description = "#{name}-#{owner}" if description.blank?
  end
end
