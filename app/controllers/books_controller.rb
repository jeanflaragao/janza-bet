class BooksController < ApplicationController
  before_action :set_book, only: %i[ show edit update destroy ]

  def index
    @books = Book.includes(:transactions).where(books: {user: Current.user}).order(:inactive, :description)
  end

  def show; end

  def new
    @book = Book.new
  end

def edit
  Rails.logger.info "=== INÍCIO CÁLCULO DE LUCRO ==="
  
  @total_deposit = @book.transactions.where(transaction_type: 'deposit').sum(:amount)
  @total_withdraw = @book.transactions.where(transaction_type: 'withdraw').sum(:amount)
  
  Rails.logger.info "Total depósitos: #{@total_deposit}"
  Rails.logger.info "Total saques: #{@total_withdraw}"

  # Busca saldos diários
  daily_balances = @book.daily_balances.order(date: :asc)
  Rails.logger.info "Encontrados #{daily_balances.count} registros de saldo diário"

  # Prepara transações agrupadas
  transactions_by_day = @book.transactions
                         .group("DATE(date)", :transaction_type)
                         .sum(:amount)
                         .each_with_object({}) do |((date, type), amount), hash|
    hash[[date.to_date, type]] = amount
    Rails.logger.debug "Transação: #{date} | #{type} | R$ #{amount}"
  end

  @daily_profit = {}
  
  @accumulated_profit = {}
  accumulated_deposits = 0
  accumulated_withdrawals = 0
  
  daily_balances.each do |balance|
    date_key = balance.date.to_date
    
    daily_deposit = transactions_by_day.fetch([date_key, 'deposit'], 0)
    daily_withdraw = transactions_by_day.fetch([date_key, 'withdraw'], 0)
    
    accumulated_deposits += daily_deposit
    accumulated_withdrawals += daily_withdraw
    
    # Fórmula: (Saldo atual + Saques acumulados) - Depósitos acumulados
    @accumulated_profit[date_key] = (balance.balance + accumulated_withdrawals) - accumulated_deposits
  end

  @last_daily_balance = daily_balances.last&.balance || 0
  @total_profit = (@last_daily_balance + @total_withdraw) - @total_deposit
  
  Rails.logger.info "Último saldo: R$ #{@last_daily_balance}"
  Rails.logger.info "Lucro total calculado: R$ #{@total_profit}"
  Rails.logger.info "=== FIM CÁLCULO DE LUCRO ==="
end

  def create
    @book = Current.user.books.new(book_params)
    if @book.save
      flash.now[:notice] = "Book was successfully created."
      render turbo_stream: [
      turbo_stream.prepend("books", @book),
      turbo_stream.replace("form_book", partial: "form", locals: { book: Book.new }
      ),
      turbo_stream.replace("notice", partial: "layouts/flash")
    ]
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @book = Book.find(params[:id])
    
    if @book.update(book_params)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace(@book, partial: "books/book", locals: { book: @book }),
            turbo_stream.replace("flash", partial: "shared/flash", locals: { notice: "Book updated" })
          ]
        end
        format.html { redirect_to books_path, notice: "Book updated" }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @book.destroy
    flash.now[:notice] = "Book was successfully destroyed."
    render turbo_stream: [
      turbo_stream.remove(@book),
      turbo_stream.replace("notice", partial: "layouts/flash")
    ]
  end

  def transactions
    @book = Book.find(params[:id])
    @transactions = @book.transactions
  
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.replace("transactions_modal", partial: "books/transactions_modal", locals: { transactions: @transactions }) }
      format.html { render "books/transactions" } # Fallback for non-turbo requests
    end
  end
  

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_book
      @book = Book.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def book_params
      params.expect(book: [ :owner, :name, :description, :inactive ])
    end
end
