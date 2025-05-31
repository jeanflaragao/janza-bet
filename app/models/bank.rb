class Bank < ApplicationRecord
  belongs_to :user
  
  validates :month, presence: true, uniqueness: { scope: :user_id }
  validates :bank_value, presence: true, numericality: true

  def total_balance
    @total_balance
  end

  def total_balance=(value)
    @total_balance = value
  end

  def total_deposits
    @total_deposits
  end

  def total_deposits=(value)
    @total_deposits = value
  end

  def total_withdrawals
    @total_withdrawals
  end

  def total_withdrawals=(value)
    @total_withdrawals = value
  end

  def total_profit
    @total_profit
  end

  def total_profit=(value)
    @total_profit = value
  end
end
