class TransactionsController < ApplicationController
  def index
    @transactions =  Transaction.joins(:book).where(books: { user_id: current_user.id }).order(date: :desc).page(params[:page]).per(25)
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
      turbo_stream.prepend("transactions", @transaction),
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

  def destroy
    @transaction.destroy
    flash.now[:notice] = "Transaction was successfully destroyed."
    render turbo_stream: [
      turbo_stream.remove(@transaction),
      turbo_stream.replace("notice", partial: "layouts/flash")
    ]
  end

  private

  def transaction_params
    params.require(:transaction).permit(:date, :book_id, :amount, :transaction_type)
  end
end
