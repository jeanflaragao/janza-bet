class BetsController < ApplicationController
  before_action :set_bet, only: %i[ show edit update destroy ]

  def index
    @bets = Current.user.bets.all
  end

  def show; end

  def new
    @bet = Bet.new
  end

  def edit
    @bet = Bet.find(params[:id])
    render partial: "bet", locals: { bet: @bet }
  end

  def inline_edit
    @bet = Bet.find(params[:id])
    render partial: "bet", locals: { bet: @bet }, formats: [:html], status: :ok
  end
  

  def create
    @bet = Current.user.bets.new(bet_params)

    if @bet.save
      flash.now[:notice] = "Bet was successfully created."
      render turbo_stream: [
      turbo_stream.prepend("bets", @bet),
      turbo_stream.replace("form_bet", partial: "form", locals: { bet: Bet.new }
      ),
      turbo_stream.replace("notice", partial: "layouts/flash")
    ]
    else
      flash.now[:alert] = @bet.errors.full_messages.join(", ")
      render turbo_stream: [
      turbo_stream.replace("notice", partial: "layouts/flash")
    ], status: :unprocessable_entity
    end

    puts @bet.errors.full_messages
  end

  def update
    @bet = Bet.find(params[:id])
    if @bet.update(bet_params)
      respond_to do |format|
        format.turbo_stream { render partial: "bet", locals: { bet: @bet } }
        format.html { redirect_to bets_path, notice: "Bet updated." }
      end
    else
      render partial: "bet", locals: { bet: @bet }
    end
  end

  def destroy
    @bet.destroy
    flash.now[:notice] = "Bet was successfully destroyed."
    render turbo_stream: [
      turbo_stream.remove(@bet),
      turbo_stream.replace("notice", partial: "layouts/flash")
    ]
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_bet
      @bet = Bet.find(params[:id])
    end
    

    # Only allow a list of trusted parameters through.
    def bet_params
      params.require(:bet).permit(
        :event_date, :game, :bet, :stake, :odd, :status, :book_id, :tipster_id
      )
    end
end
