class ItemsController < ApplicationController
  
  before_filter :require_user, only: [:new, :create, :edit, :update]
    
  respond_to :html, :js, :json
  
  autocomplete :item, :name, :full => true, :extra_data => [:user_id]
  
  
  # GET /users/:user_id/items
  def index
    @user = User.find(params[:user_id])
  	
    @current = current_user
    @items = Item.visibleToUser(@current, @user)
     
    respond_with(@user,@items)
  end
  
  # Get /users/:user_id/items/new
  def new
  	@item = Item.new
    @user = current_user
    
    respond_with(@item)
  end
  
  # GET /users/:user_id/items/:id
  def show
    @user = User.find(params[:user_id])
  	
	@current = current_user
	@item = @user.items.find(params[:id]).authorize_to_show(@current)
	
	if @item
		@relatives = @item.network_as_json(@current).html_safe
	else
		redirect_to root_url and return
	end
	
	respond_to do |format|
      format.html { respond_with(@item, @user) }
      format.json { respond_with(@relatives) }
    end
  end
  
  # POST /users/:user_id/items
  def create
    
    @user = current_user
	
	@addtomap = false
	
	if params[:initem] 
		if params[:initem] != ""
			@addtomap = true
			@itemid = params[:initem]
		end
	end
	
	if @addtomap
			@item = Item.find(@itemid)
	else
		@item = Item.new()
		@item.name = params[:item][:name]
		@item.desc = ""
		@item.link = ""
		@item.permission = 'commons'
        @item.item_category = ItemCategory.all.first
		#@item.item_category = ItemCategory.find(params[:category])
		@item.user = @user

		@item.save
    end		

    @position = Hash.new()
    @position['x'] = params[:item][:x]
    @position['y'] = params[:item][:y]
	
	@mapping = Mapping.new()
	if params[:item][:map]
		@mapping.category = "Item"
		@mapping.user = @user
		@mapping.map = Map.find(params[:item][:map])
		@mapping.item = @item
		@mapping.xloc = 0
		@mapping.yloc = 0
		@mapping.save
	end
    
    respond_to do |format|
      format.html { respond_with(@user, location: user_item_url(@user, @item)) }
      format.js { respond_with(@item, @mapping, @position) }
    end
    
  end
  
  # GET /users/:user_id/items/:id/edit
  def edit
	@user = User.find(params[:user_id])
  	
	@current = current_user
	@item = @user.items.find(params[:id]).authorize_to_edit(@current)
	
	if not @item
		redirect_to root_url and return
	end
  
	respond_with(@item)
  end
  
  # PUT /users/:user_id/items/:id
  def update
	@user = User.find(params[:user_id])
  	
	@item = @user.items.find(params[:id])
    
	if @item 
		@item.name = params[:item][:name]
		@item.desc = params[:item][:desc]
		@item.link = params[:item][:link]
		@item.permission = params[:item][:permission]
		@item.item_category = ItemCategory.find(params[:category][:item_category_id])
	
		@item.save
    end
	
    respond_with(@user, location: user_item_url(@user, @item)) do |format|
    end
	
  end
  
  # DELETE /users/:user_id/items/:id
  def destroy
	@user = User.find(params[:user_id])
  	
	@item = @user.items.find(params[:id])
	
	@synapses = @item.synapses
	@mappings = @item.mappings
	
	@synapses.each do |synapse| 
		synapse.delete
	end
	
	@mappings.each do |mapping| 
		mapping.delete
	end
	
	@item.delete
	
	respond_to do |format|
      format.js
    end
  end
  
end
