class HomeController < ApplicationController
  def index
    @daily_balances = DailyBalance.where(date: Date.current.beginning_of_month..Date.current)
    @total_deposits = Transaction.where(transaction_type: 'deposit').sum(:amount)
    @total_withdrawals = Transaction.where(transaction_type: 'withdrawal').sum(:amount)
    @last_balance = DailyBalance.order(date: :desc).first&.balance || 0
  end
end
