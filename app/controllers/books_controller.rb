class BooksController < ApplicationController
  before_action :set_book, only: %i[ show edit update destroy ]

  def index
    @books = Current.user.books.order(:inactive, :description)
  end

  def show; end

  def new
    @book = Book.new
  end

  def edit; end

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
