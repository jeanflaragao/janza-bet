class BetsController < ApplicationController
  before_action :set_bet, only: %i[ show edit inline_edit update destroy ]

  def index
    @bets = Current.user.bets.order(event_date: :desc)
  end

  def show; end

  def new
    @bet = Bet.new
  end

  def edit
    render partial: "bet", locals: { bet: @bet }
  end

  def inline_edit
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          dom_id(@bet),
          partial: "bets/bet",
          locals: { bet: @bet, editing: true }
        )
      end
      format.html { redirect_to bets_path }
    end
  end

  def create
    @bet = Current.user.bets.new(bet_params)

    if @bet.save
      flash.now[:notice] = "Aposta criada com sucesso."
      render turbo_stream: [
        turbo_stream.prepend("bets", partial: "bets/bet", locals: { bet: @bet }),
        turbo_stream.replace("form_bet", partial: "form", locals: { bet: Bet.new }),
        turbo_stream.replace("notice", partial: "layouts/flash")
      ]
    else
      flash.now[:alert] = @bet.errors.full_messages.join(", ")
      render turbo_stream: [
        turbo_stream.replace("notice", partial: "layouts/flash")
      ], status: :unprocessable_entity
    end
  end

  def update
    if @bet.update(bet_params)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            dom_id(@bet),
            partial: "bets/bet",
            locals: { bet: @bet }
          )
        end
        format.html { redirect_to bets_path, notice: "Aposta atualizada." }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            dom_id(@bet),
            partial: "bets/bet",
            locals: { bet: @bet, editing: true }
          ), status: :unprocessable_entity
        end
        format.html { render :edit }
      end
    end
  end

  def destroy
    @bet.destroy
    flash.now[:notice] = "Aposta excluída."
    render turbo_stream: [
      turbo_stream.remove(@bet),
      turbo_stream.replace("notice", partial: "layouts/flash")
    ]
  end

  private
    def set_bet
      @bet = current_user.bets.find(params[:id])
    end

    def bet_params
      params.require(:bet).permit(
        :event_date, :game, :bet, :stake, :odd, :status, :book_id, :tipster_id
      )
    end
end
