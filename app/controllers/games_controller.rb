class GamesController < ApplicationController
  before_action :set_game, only: [:show, :edit, :update, :destroy]
  require 'json'
  # GET /games
  # GET /games.json
  def index
    @games = Game.all
  end
  # GET /games/1
  # GET /games/1.json
  def show
   @game = Game.find(params[:id])
  end

  # GET /games/new
  def new
    @game = Game.new
  end

  # GET /games/1/edit
  def edit
  end

  # POST /games
  # POST /games.json
  def create
    @game = Game.new(game_params)

    respond_to do |format|
      if @game.save
        format.html { redirect_to @game, notice: 'Game was successfully created.' }
        format.json { render :show, status: :created, location: @game }
      else
        format.html { render :new }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /games/1
  # PATCH/PUT /games/1.json
  def update
    respond_to do |format|
      if @game.update(game_params)
        format.html { redirect_to @game, notice: 'Game was successfully updated.' }
        format.json { render :show, status: :ok, location: @game }
      else
        format.html { render :edit }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /games/1
  # DELETE /games/1.json
  def destroy
    @game.destroy
    respond_to do |format|
      format.html { redirect_to games_url, notice: 'Game was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  ### Additional controller methods
  def list 
    @games = Game.all
  end

  ### CLASS METHODS
  def self.populate
    file = File.read("Games-complete")
    doc = JSON.parse(file)
    doc.each do |n|
      tmp= Game.new(
          "game"=>n["game"],
          "score"=>n["score"],
          "description"=>n["description"],
          "tags"=>n["tags"],
          "publisher"=>n["publisher"],
          "published"=>n["published"],
          "image"=>n["image"])
      tmp.save!
      tmp = ""
    end

  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_game
      @game = Game.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def game_params
      params.require(:game).permit(:game, :score, :description, :image, :review_count)
  end
end
