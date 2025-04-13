class HomeController < ApplicationController
  def index
    @daily_balances = DailyBalance.where(date: Date.current.beginning_of_month..Date.current)
    @total_deposits = Transaction.where(transaction_type: 'deposit').sum(:amount)
    @total_withdrawals = Transaction.where(transaction_type: 'withdraw').sum(:amount)
    last_date = DailyBalance.maximum(:date)
    @last_balance = last_date ? DailyBalance.where(date: last_date).sum(:balance) : 0

    @profit_total = (@last_balance + @total_withdrawals) - @total_deposits
  end
end
