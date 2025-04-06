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
      flash.now[:notice] = "Transaction was successfully created."
      render turbo_stream: [
      turbo_stream.prepend("transaction", @transaction),
      turbo_stream.replace("form_transaction", partial: "form", locals: { transaction: Transaction.new }
      ),
      turbo_stream.replace("notice", partial: "layouts/flash")
    ]
    else
      flash.now[:alert] = @transaction.errors.full_messages.join(", ")
      render turbo_stream: [
      turbo_stream.replace("notice", partial: "layouts/flash")
    ], status: :unprocessable_entity
    end

    puts @transaction.errors.full_messages
  end

  private

  def transaction_params
    params.require(:transaction).permit(:date, :book_id, :amount, :transaction_type)
  end
end
