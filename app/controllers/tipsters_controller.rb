class TipstersController < ApplicationController
  before_action :set_tipster, only: %i[ show edit update destroy ]

  # GET /tipsters or /tipsters.json
  def index
    @tipsters = Tipster.all
  end

  # GET /tipsters/1 or /tipsters/1.json
  def show
  end

  # GET /tipsters/new
  def new
    @tipster = Tipster.new
  end

  # GET /tipsters/1/edit
  def edit
  end

  # POST /tipsters or /tipsters.json
  def create
    @tipster = Tipster.new(tipster_params)

    respond_to do |format|
      if @tipster.save
        format.html { redirect_to @tipster, notice: "Tipster was successfully created." }
        format.json { render :show, status: :created, location: @tipster }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @tipster.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tipsters/1 or /tipsters/1.json
  def update
    respond_to do |format|
      if @tipster.update(tipster_params)
        format.html { redirect_to @tipster, notice: "Tipster was successfully updated." }
        format.json { render :show, status: :ok, location: @tipster }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @tipster.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tipsters/1 or /tipsters/1.json
  def destroy
    @tipster.destroy!

    respond_to do |format|
      format.html { redirect_to tipsters_path, status: :see_other, notice: "Tipster was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tipster
      @tipster = Tipster.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def tipster_params
      params.expect(tipster: [ :name, :status ])
    end
end
