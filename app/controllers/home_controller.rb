class HomeController < ApplicationController
  def index
    @daily_balances = DailyBalance.where(date: Date.current.beginning_of_month..Date.current)
  end
end
