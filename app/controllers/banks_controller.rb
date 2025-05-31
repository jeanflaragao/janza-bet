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


      amount_first_day = DailyBalance.joins(:book)
                  .where(books: { user_id: current_user.id })
                  .where(date: @bank.month.beginning_of_month)
                  .sum(:balance)
      
      @bank.cash_money = (@bank.bank_value + @bank.total_withdrawals) - (amount_first_day + @bank.total_deposits);
      
      @daily_balances = DailyBalance.joins(:book)
                          .where(books: { user_id: current_user.id })
                          .where(date: date_range)
                          .order(:date)
      
      @cumulative_profits = calculate_cumulative_profits(date_range, current_user)
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

    def calculate_cumulative_profits(date_range, user)
  cumulative_data = []
  cumulative_profit = 0
  initial_balance = DailyBalance.joins(:book)
                      .where(books: { user_id: user.id })
                      .where(date: @bank.month.beginning_of_month)
                      .sum(:balance) || 0
  
  # Obter todos os saldos diários ordenados por data
  daily_balances = DailyBalance.joins(:book)
                    .where(books: { user_id: user.id })
                    .where(date: date_range)
                    .order(:date)
                    .pluck(:date, :balance)
  
  # Obter todas as transações agrupadas por dia
  daily_transactions = Transaction.joins(:book)
                        .where(books: { user_id: user.id })
                        .where(date: date_range)
                        .group(:date)
                        .group(:transaction_type)
                        .sum(:amount)
  
  # Processar cada dia do mês (incluindo dias sem movimentação)
  (date_range.first..date_range.last).each do |date|
    balance = daily_balances.find { |d, _| d == date }&.last || (date == date_range.first ? initial_balance : nil)
    
    # Só processar se tivermos saldo para o dia (ou for o primeiro dia)
    if balance || date == date_range.first
      balance ||= initial_balance
      
      # Encontrar transações do dia
      deposits = daily_transactions[[date, 'deposit']] || 0
      withdrawals = daily_transactions[[date, 'withdraw']] || 0
      
      # Calcular lucro do dia: (Saldo atual - Saldo anterior) + Saques - Depósitos
      previous_balance = if date == date_range.first
                          initial_balance
                        else
                          prev_date = date - 1.day
                          daily_balances.find { |d, _| d == prev_date }&.last || initial_balance
                        end
      
      daily_profit = (balance - previous_balance) + withdrawals - deposits
      cumulative_profit += daily_profit
      
      cumulative_data << [date, cumulative_profit]
    end
  end
  
  cumulative_data
end

    
end
