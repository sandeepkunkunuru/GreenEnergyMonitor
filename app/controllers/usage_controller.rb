class UsageController < ApplicationController
  before_action :set_usage, only: [:show, :edit, :update, :destroy]

  # GET /usage
  # GET /usage.json
  def index
    @usage = Usage.paginate(:page => params[:page])
  end

  # GET /usage/1
  # GET /usage/1.json
  def show
  end

  # GET /usage/new
  def new
    @usage = Usage.new
  end

  # GET /usage/1/edit
  def edit
  end

  # POST /usage
  # POST /usage.json
  def create
    @usage = Usage.new(usage_params)

    respond_to do |format|
      if @usage.save
        format.html { redirect_to @usage, notice: 'Usage was successfully created.' }
        format.json { render action: 'show', status: :created, location: @usage }
      else
        format.html { render action: 'new' }
        format.json { render json: @usage.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /usage/1
  # PATCH/PUT /usage/1.json
  def update
    respond_to do |format|
      if @usage.update(usage_params)
        format.html { redirect_to @usage, notice: 'Usage was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @usage.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /usage/1
  # DELETE /usage/1.json
  def destroy
    @usage.destroy
    respond_to do |format|
      format.html { redirect_to usage_index_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_usage
      @usage = Usage.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def usage_params
      params[:usage]
    end
end
