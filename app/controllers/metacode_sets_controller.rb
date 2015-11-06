class MetacodeSetsController < ApplicationController
  
  before_filter :require_admin

  # GET /metacode_sets
  # GET /metacode_sets.json
  def index
    @metacode_sets = MetacodeSet.order("name").all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @metacode_sets }
    end
  end

  # GET /metacode_sets/new
  # GET /metacode_sets/new.json
  def new
    @metacode_set = MetacodeSet.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @metacode_set }
    end
  end

  # GET /metacode_sets/1/edit
  def edit
    @metacode_set = MetacodeSet.find(params[:id])
  end

  # POST /metacode_sets
  # POST /metacode_sets.json
  def create
    @metacode_set = MetacodeSet.new(metacode_set_params)
    @metacode_set.user_id = current_user.id
    @metacode_set.metacode_ids = params[:metacodes][:value].split(',') #TODO is this a security hole?

    respond_to do |format|
      if @metacode_set.save
        format.html { redirect_to metacode_sets_url, notice: 'Metacode set was successfully created.' }
        format.json { render json: @metacode_set, status: :created, location: metacode_sets_url }
      else
        format.html { render action: "new" }
        format.json { render json: @metacode_set.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /metacode_sets/1
  # PUT /metacode_sets/1.json
  def update
    @metacode_set = MetacodeSet.find(params[:id])
    @metacode_set.metacode_ids = params[:metacodes][:value].split(',') #TODO is this a security hole?

    respond_to do |format|
      if @metacode_set.update_attributes(metacode_set_params)
        format.html { redirect_to metacode_sets_url, notice: 'Metacode set was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @metacode_set.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /metacode_sets/1
  # DELETE /metacode_sets/1.json
  def destroy
    @metacode_set = MetacodeSet.find(params[:id])
    
    @metacode_set.destroy

    respond_to do |format|
      format.html { redirect_to metacode_sets_url }
      format.json { head :no_content }
    end
  end

  private

  def metacode_set_params
    params.require(:metacode_set).permit(:desc, :mapperContributed, :name)
  end
end
