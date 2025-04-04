class TransactionsController < ApplicationController
  def index
    @transactions = Transaction.includes(:book).order(date: :desc)
  end

  def edit
    @transaction = Transaction.find(params[:id])
  end
  
  def new
    @transaction = Transaction.new
  end

  def create
    @transaction = Transaction.new(transaction_params)
    if @transaction.save
      redirect_to transactions_path, notice: "Transaction created successfully."
    else
      render :new
    end
  end

  private

  def transaction_params
    params.require(:transaction).permit(:book_id, :amount, :transaction_type)
  end
end
