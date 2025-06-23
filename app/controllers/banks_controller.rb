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
    # Define o intervalo do mês atual
    date_range = @bank.month.beginning_of_month..@bank.month.end_of_month
    
    # Calcula o último dia do mês anterior
    last_day_previous_month = @bank.month.prev_month.end_of_month

    # Busca as transações do mês atual
    transactions = Transaction.joins(:book)
                    .where(books: { user_id: current_user.id })
                    .where(date: date_range)

    @bank.total_deposits = transactions.where(transaction_type: 'deposit').sum(:amount)
    @bank.total_withdrawals = transactions.where(transaction_type: 'withdraw').sum(:amount)
    @bank.total_balance = sum_of_last_day_balance(@bank, current_user)

    # Busca o saldo do último dia do mês anterior
    amount_last_day_previous_month = DailyBalance.joins(:book)
                .where(books: { user_id: current_user.id })
                .where(date: last_day_previous_month)
                .sum(:balance)

    initial_balance = if @bank.month.today? && Date.today.day == 1
                    amount_previous_month_end
                  else
                    0
                  end

    # Calcula o dinheiro em caixa
    @bank.cash_money = (@bank.bank_value + @bank.total_withdrawals) - (initial_balance + @bank.total_deposits)              
    
    @cumulative_profits = calculate_cumulative_profits(date_range, current_user, amount_last_day_previous_month)
  end

  def create
    @bank = current_user.banks.new(bank_params)

    if @bank.save
      flash.now[:notice] = "Mês criado com sucesso."
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

    def calculate_cumulative_profits(date_range, user, amount_last_day_previous_month)
      cumulative_data = []
      cumulative_profit = 0
      previous_balance = amount_last_day_previous_month
      
      
      #puts "\n=== CÁLCULO DE LUCRO ACUMULADO ==="
      #puts "Data Inicial: #{date_range.first}, Data Final: #{date_range.last}"
      #puts "Saldo do último dia do mês anterior: R$#{amount_last_day_previous_month.to_f.round(2)}"
      

      # Obter todos os saldos diários
      daily_balances = DailyBalance.joins(:book)
                        .where(books: { user_id: user.id })
                        .where(date: date_range)
                        .group(:date)          # Agrupa por data
                        .order(:date)          # Ordena por data
                        .sum(:balance)         # Soma o saldo de cada grupo
                        .to_h

      #puts "\nSaldos Diários:"
      #daily_balances.each { |date, balance| puts "#{date}: R$#{
      #  balance.to_f.round(2)}" }

      # Obter todas as transações
      daily_transactions = Transaction.joins(:book)
                              .where(books: { user_id: user.id })
                              .where(date: date_range)
                              .group("DATE(date)", :transaction_type)  # Agrupa apenas pela data (sem hora)
                              .order("DATE(date)")                     # Ordena pela data (sem hora)
                              .sum(:amount)

      #puts "\nTransações Diárias:"
      #daily_transactions.each { |(date, type), amount| puts "#{date} | #{type}: R$#{amount.to_f.round(2)}" }

      (date_range.first..date_range.last).each do |date|
        current_balance = daily_balances[date]
        
        unless current_balance
          #puts "\n#{date}: Sem saldo registrado - pulando"
          next
        end

        deposits = daily_transactions[[date, 'deposit']] || 0
        withdrawals = daily_transactions[[date, 'withdraw']] || 0

        #puts "\n--- Dia #{date} ---"
        #puts "Saldo Anterior: R$#{previous_balance.to_f.round(2)}"
        #puts "Saldo Atual: R$#{current_balance.to_f.round(2)}"
        #puts "Depósitos: R$#{deposits.to_f.round(2)}"
        #puts "Saques: R$#{withdrawals.to_f.round(2)}"

        # Cálculo do lucro diário (sempre comparando com o dia anterior)
        daily_profit = (current_balance - previous_balance) + withdrawals - deposits
        #puts "Cálculo: (#{current_balance} - #{previous_balance}) + #{withdrawals} - #{deposits} = R$#{daily_profit.round(2)}"

        cumulative_profit += daily_profit
        cumulative_data << [date, cumulative_profit.round(2)]
        
        #puts "Lucro Acumulado: R$#{cumulative_profit.round(2)}"
        previous_balance = current_balance
      end

      #puts "\n=== RESULTADO FINAL ==="
      #cumulative_data.each { |date, profit| puts "#{date}: R$#{profit}" }

      cumulative_data
    end

    
end
