class HomeController < ApplicationController
  def index
    case params[:filter]
    when "month"
      start_date = Date.current.beginning_of_month
      date_range = start_date..Date.current
    when "semester"
      start_date = Date.current.beginning_of_year
      date_range = start_date..Date.current
    else # default: all time
      date_range = nil
    end

    @daily_balances = DailyBalance.where(date: start_date..Date.current)
    @total_deposits = Transaction.where(transaction_type: 'deposit', date: start_date..Date.current).sum(:amount)
    @total_withdrawals = Transaction.where(transaction_type: 'withdraw', date: start_date..Date.current).sum(:amount)
    last_date = DailyBalance.where(date: start_date..Date.current).maximum(:date)
    @last_balance = last_date ? DailyBalance.where(date: last_date).sum(:balance) : 0

    @profit_total = (@last_balance + @total_withdrawals) - @total_deposits
  end
end
