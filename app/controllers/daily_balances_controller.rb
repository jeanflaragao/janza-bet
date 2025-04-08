class DailyBalancesController < ApplicationController
  before_action :set_daily_balance, only: [:edit, :update, :destroy]
  include ActionView::RecordIdentifier

  def index
    @books = Book.all
    params[:date] ||= Date.today.to_s

    @daily_balances = DailyBalance.all
    @daily_balances = @daily_balances.where(date: params[:date]) if params[:date].present?
    @daily_balances = @daily_balances.where(book_id: params[:book_id]) if params[:book_id].present?

    if params[:editing]
      @editing_balance = @daily_balances.find { |b| dom_id(b) == params[:editing] }

      if @editing_balance
        render partial: "daily_balance", locals: { balance: @editing_balance }, layout: false
        return
      end
    end
  end

  def update
    @balance = DailyBalance.find(params[:id])

    if @balance.update(daily_balance_params)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(dom_id(@balance), partial: "daily_balance", locals: { balance: @balance })
        end
        format.html do
          redirect_to daily_balances_path, notice: "Balance updated."
        end
      end
    else
      render partial: "daily_balance", locals: { balance: @balance }
    end
  end

  def edit
    redirect_to daily_balances_path(editing: dom_id(@daily_balance))
  end

  def destroy
    @daily_balance.destroy
    redirect_to daily_balances_path
  end

  def add_for_date
    date = params[:date]

    if date.blank?
      redirect_to daily_balances_path, alert: "Please select a date."
      return
    end

    Book.find_each do |book|
      DailyBalance.find_or_create_by(book: book, date: date) do |balance|
        balance.balance = 0.0
      end
    end

    redirect_to daily_balances_path, notice: "Balances added for #{date}."
  end

  private

  def set_daily_balance
    @daily_balance = DailyBalance.find(params[:id])
  end

  def daily_balance_params
    params.require(:daily_balance).permit(:date, :balance, :book_id)
  end
end
