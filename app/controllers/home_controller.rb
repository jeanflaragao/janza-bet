class HomeController < ApplicationController
  def index
    case params[:filter]
    when "month"
      start_date = Date.current.beginning_of_month
      end_date = Date.current
    when "last_month"
      start_date = Date.current.last_month.beginning_of_month
      end_date = Date.current.last_month.end_of_month
    when "semester"
      start_date = Date.current.beginning_of_year
      end_date = Date.current
    else # all time
      start_date = nil
      end_date = nil
    end

    date_range = start_date && end_date ? (start_date..end_date) : nil

    transactions = Transaction.all
    transactions = transactions.where(date: date_range) if date_range

    @total_deposits = transactions.where(transaction_type: 'deposit').sum(:amount)
    @total_withdrawals = transactions.where(transaction_type: 'withdraw').sum(:amount)
    net_contribution = @total_deposits - @total_withdrawals

    daily_balances = DailyBalance.all
    daily_balances = daily_balances.where(date: date_range) if date_range
    last_date = daily_balances.maximum(:date)

    use_balance = true
    if params[:filter] == "month" && Date.current.day == 1
      use_balance = daily_balances.where(date: Date.current).exists?
    end

    @last_balance = last_date ? daily_balances.where(date: last_date).sum(:balance) : 0
    @profit_total = use_balance ? (@last_balance - net_contribution) : 0

    @daily_balances = daily_balances
  end
end
