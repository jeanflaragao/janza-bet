class BetsController < ApplicationController
  before_action :set_bet, only: %i[ show edit update destroy ]

  # GET /bets or /bets.json
  def index
    @bets = Current.user.bets.all
  end

  # GET /bets/1 or /bets/1.json
  def show
  end

  # GET /bets/new
  def new
    @bet = Bet.new
  end

  # GET /bets/1/edit
  def edit
  end

  # POST /bets or /bets.json
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
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /bets/1 or /bets/1.json
  def update
    if @bet.update(bet_params)
      flash.now[:notice] = "Bet was successfully updated."
      render turbo_stream: [
        turbo_stream.replace(@bet, @bet),
        turbo_stream.replace("notice", partial: "layouts/flash")
      ]
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @bet.destroy
    flash.now[:notice] = "BBetook was successfully destroyed."
    render turbo_stream: [
      turbo_stream.remove(@bet),
      turbo_stream.replace("notice", partial: "layouts/flash")
    ]
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_bet
      @bet = Bet.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def bet_params
      params.expect(bet: [ :event_date, :game, :bet, :stake, :odd, :status, :book_id, :tipster_id, :result ])
    end
end
