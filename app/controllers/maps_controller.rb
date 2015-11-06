class MapsController < ApplicationController
    before_filter :require_user, only: [:create, :update, :screenshot, :destroy]

    respond_to :html, :json

    autocomplete :map, :name, :full => true, :extra_data => [:user_id]

    # GET /explore/active
    # GET /explore/featured
    # GET /explore/mapper/:id
    def index
        if request.path == "/explore"
            redirect_to activemaps_url and return
        end

        @current = current_user
        @user = nil
        @maps = []
        @mapperId = nil

        if !params[:page] 
            page = 1
        else 
            page = params[:page]
        end

        if request.path.index("/explore/active") != nil
            @maps = Map.where("maps.permission != ?", "private").order("updated_at DESC").page(page).per(20)
            @request = "active"

        elsif request.path.index("/explore/featured") != nil
            @maps = Map.where("maps.featured = ? AND maps.permission != ?", true, "private").order("updated_at DESC").page(page).per(20)
            @request = "featured"

        elsif request.path.index('/explore/mine') != nil  # looking for maps by me
            if !authenticated?
                redirect_to activemaps_url and return
            end
            # don't need to exclude private maps because they all belong to you
            @maps = Map.where("maps.user_id = ?", @current.id).order("updated_at DESC").page(page).per(20)
            @request = "you"

        elsif request.path.index('/explore/mapper/') != nil  # looking for maps by a mapper
            @user = User.find(params[:id])
            @maps = Map.where("maps.user_id = ? AND maps.permission != ?", @user.id, "private").order("updated_at DESC").page(page).per(20)
            @request = "mapper"
        end

        respond_to do |format|
            format.html { 
                if @request == "active" && authenticated?
                    redirect_to root_url and return
                end
                respond_with(@maps, @request, @user)
            }
            format.json { render json: @maps }
        end
    end

    # GET maps/:id
    def show
        @map = Map.find(params[:id]).authorize_to_show(current_user)

        if not @map
            redirect_to root_url, notice: "Access denied. That map is private." and return
        end

        respond_to do |format|
            format.html { 
                @map = MapFacade.new(@map)
                respond_with(@map)
            }
            format.json { render json: @map }
        end
    end

    # GET maps/:id/contains
    def contains
        @map = Map.find(params[:id]).authorize_to_show(current_user)

        if not @map
            redirect_to root_url, notice: "Access denied. That map is private." and return
        end

        @map = MapFacade.new(@map)

        respond_to do |format|
            format.json { render json: @map.json_contains }
        end
    end

    # POST maps
    def create

        @user = current_user
        @map = Map.new()
        @map.name = params[:name]
        @map.desc = params[:desc]
        @map.permission = params[:permission]
        @map.user = @user
        @map.arranged = false 
        @map.save     

        if params[:topicsToMap]
            @all = params[:topicsToMap]
            @all = @all.split(',')
            @all.each do |topic|
                topic = topic.split('/')
                @mapping = Mapping.new()
                @mapping.user = @user
                @mapping.map  = @map
                @mapping.mappable = Topic.find(topic[0])
                @mapping.xloc = topic[1]
                @mapping.yloc = topic[2]
                @mapping.save
            end

            if params[:synapsesToMap]
                @synAll = params[:synapsesToMap]
                @synAll = @synAll.split(',')
                @synAll.each do |synapse_id|
                    @mapping = Mapping.new()
                    @mapping.user = @user
                    @mapping.map = @map
                    @mapping.mappable = Synapse.find(synapse_id)
                    @mapping.save
                end
            end

            @map.arranged = true
            @map.save      
        end

        respond_to do |format|
            format.json { render :json => @map }
        end
    end

    # PUT maps/:id
    def update
        @map = Map.find(params[:id]).authorize_to_edit(current_user)

        respond_to do |format|
            if @map.nil?
                format.json { render json: "unauthorized" }
            elsif @map.update_attributes(map_params)
                format.json { head :no_content }
            else
                format.json { render json: @map.errors, status: :unprocessable_entity }
            end
        end
    end

    # POST maps/:id/upload_screenshot
    def screenshot
      @map = Map.find(params[:id]).authorize_to_edit(current_user)

      if @map
        png = Base64.decode64(params[:encoded_image]['data:image/png;base64,'.length .. -1])
        StringIO.open(png) do |data|
          data.class.class_eval { attr_accessor :original_filename, :content_type }
          data.original_filename = "map-" + @map.id.to_s + "-screenshot.png"
          data.content_type = "image/png"
          @map.screenshot = data
        end
        
        if @map.save
          render :json => {:message => "Successfully uploaded the map screenshot."}
        else
          render :json => {:message => "Failed to upload image."}
        end
      else
        render :json => {:message => "Unauthorized to set map screenshot."}
      end
    end

    # DELETE maps/:id
    def destroy
      @map = Map.find(params[:id]).authorize_to_delete(current_user)
      if @map
        @map.delete
        render json: "success"
      else
        render json: "unauthorized"
      end
    end

    private

    # Never trust parameters from the scary internet, only allow the white list through.
    def map_params
      params.require(:map).permit(:id, :name, :arranged, :desc, :permission, :user_id)
    end
end
