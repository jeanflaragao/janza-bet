class DailyBalancesController < ApplicationController
    before_action :set_daily_balance, only: [:edit, :update, :destroy]

    def index
        @books = Book.all
      
        # Set today's date as default filter if no date is provided
        params[:date] ||= Date.today.to_s
      
        @daily_balances = DailyBalance.all
        @daily_balances = @daily_balances.where(date: params[:date]) if params[:date].present?
        @daily_balances = @daily_balances.where(book_id: params[:book_id]) if params[:book_id].present?
      end
  
    def edit
      redirect_to daily_balances_path(editing: dom_id(@daily_balance))
    end
  
    def update
      if @daily_balance.update(daily_balance_params)
        redirect_to daily_balances_path
      else
        render :edit, status: :unprocessable_entity
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
  
    def daily_balance_params
      params.require(:daily_balance).permit(:date, :balance, :book_id)
    end
  end
  