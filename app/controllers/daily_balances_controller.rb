class DailyBalancesController < ApplicationController
  before_action :set_daily_balance, only: [:edit, :update, :destroy]
  include ActionView::RecordIdentifier

  def index
    # Get distinct dates from the current user's books' daily balances
    @dates = DailyBalance.joins(:book)
                         .where(books: { user_id: current_user.id })
                         .select(:date)
                         .distinct
                         .order(date: :desc)
                         .map(&:date)

    @date_summaries = @dates.map do |date|
      balances = DailyBalance.joins(:book)
                            .where(date: date, books: { user_id: current_user.id })
      {
        date: date,
        total_books: balances.count,
        books_with_zero_balance: balances.where(balance: 0.0).count,
        total_balance: balances.sum(:balance)
      }
    end
  end

  def edit_by_date
    @date = params[:date]
    @balances = DailyBalance.joins(:book)
                           .includes(:book)
                           .where(date: @date, books: { user_id: current_user.id })
                           .order("books.name")
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

    current_user.books.active.find_each do |book|
      DailyBalance.find_or_create_by(book: book, date: date) do |balance|
        balance.balance = book.last_daily_balance || 0.0
      end
    end

    redirect_to daily_balances_path, notice: "Balances added for #{date}."
  end

  private

  def set_daily_balance
    @daily_balance = DailyBalance.joins(:book)
                                .where(id: params[:id], books: { user_id: current_user.id })
                                .first
    redirect_to daily_balances_path, alert: "Balance not found." unless @daily_balance
  end

  def balance_params
    params.require(:daily_balance).permit(:balance)
  end
end