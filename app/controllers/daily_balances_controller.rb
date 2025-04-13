class DailyBalancesController < ApplicationController
  before_action :set_daily_balance, only: [:edit, :update, :destroy]
  include ActionView::RecordIdentifier

  def index
    @dates = DailyBalance.select(:date).distinct.order(date: :desc).map(&:date)

    @date_summaries = @dates.map do |date|
      balances = DailyBalance.where(date: date)
      {
        date: date,
        total_books: balances.count,
        books_with_zero_balance: balances.where(balance: 0.0).count
      }
    end
  end

  def edit_by_date
    @date = params[:date]
    @balances = DailyBalance.includes(:book).where(date: @date).order("books.name")
  end

  def edit
    respond_to do |format|
      format.turbo_stream do
        render partial: "form_row", locals: { balance: @daily_balance }
      end
      format.html do
        render partial: "form_row", locals: { balance: @daily_balance }
      end
    end
  end

  def update
    if @daily_balance.update(balance_params)
      flash.now[:notice] = "Balance was successfully updated."
      render turbo_stream: [
        turbo_stream.replace(@daily_balance, partial: "daily_balances/balance_row", locals: { balance: @daily_balance }),
        turbo_stream.replace("notice", partial: "layouts/flash")
      ]
    else
      respond_to do |format|
        format.turbo_stream do
          render partial: "form_row", locals: { balance: @daily_balance }
        end
        format.html do
          render partial: "form_row", locals: { balance: @daily_balance }
        end
      end
    end
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

  def balance_params
    params.require(:daily_balance).permit(:balance)
  end
end
