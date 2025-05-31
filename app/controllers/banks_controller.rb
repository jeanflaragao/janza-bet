class BanksController < ApplicationController
  before_action :set_bank, only: %i[ show edit update destroy ]

  def index
    @banks = current_user.banks.order(month: :desc)
    @banks.each do |bank|
      bank.total_balance = sum_of_last_day_balance(bank, current_user)
    end
  end

  def show
  end

  def new
    @bank = current_user.banks.new
  end

  def edit
    date_range = @bank.month.beginning_of_month..@bank.month.end_of_month

    transactions = Transaction.joins(:book)
                     .where(books: { user_id: current_user.id })
                     .where(date: date_range)

      @bank.total_deposits = transactions.where(transaction_type: 'deposit').sum(:amount)
      @bank.total_withdrawals = transactions.where(transaction_type: 'withdraw').sum(:amount)
      @bank.total_balance = sum_of_last_day_balance(@bank, current_user)
  end

  def create
    @bank = current_user.banks.new(bank_params)

    if @bank.save
      flash.now[:notice] = "Banca foi criada com sucesso."
      render turbo_stream: [
      turbo_stream.prepend("banks", @bank),
      turbo_stream.replace("form_bank", partial: "form", locals: { bank: Bank.new }
      ),
      turbo_stream.replace("notice", partial: "layouts/flash")
    ]
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    respond_to do |format|
      if @bank.update(bank_params)
        format.html { redirect_to @bank, notice: "Bank was successfully updated." }
        format.json { render :show, status: :ok, location: @bank }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @bank.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /banks/1 or /banks/1.json
  def destroy
    @bank.destroy!

    respond_to do |format|
      format.html { redirect_to banks_path, status: :see_other, notice: "Bank was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_bank
      @bank = Bank.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def bank_params
      params.require(:bank).permit(:month, :bank_value)
    end

    def sum_of_last_day_balance(bank, current_user)
      max_date = DailyBalance.joins(:book)
                            .where(books: { user_id: current_user.id })
                            .where(date: bank.month.beginning_of_month..bank.month.end_of_month)
                            .maximum(:date)

      return 0 unless max_date # handle no data

      DailyBalance.joins(:book)
                  .where(books: { user_id: current_user.id })
                  .where(date: max_date)
                  .sum(:balance)
    end

    
end
