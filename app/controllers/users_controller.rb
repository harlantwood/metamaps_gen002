class UsersController < ApplicationController
  before_filter :require_user, only: [:edit, :update, :updatemetacodes]
  before_action :set_user, only: [:edit, :update, update_metacodes]
  before_action :find_user, only: [:show]
    
  respond_to :html, :json 

  # GET /users/1.json
  def show
    render json: @user
  end  
    
  # GET /users/:id/edit
  def edit
    respond_with(@user)  
  end
  
  # PUT /users/:id
  def update
    if user_params[:password] == "" && user_params[:password_confirmation] == ""
      # not trying to change the password
      if @user.update_attributes(user_params.except(:password, :password_confirmation))
        if params[:remove_image] == "1"
          @user.image = nil
        end
        @user.save
        sign_in(@user, :bypass => true)
        respond_to do |format|
          format.html { redirect_to root_url, notice: "Account updated!" }
        end
      else
        sign_in(@user, :bypass => true)
        respond_to do |format|
          format.html { redirect_to edit_user_path(@user), notice: @user.errors.to_a[0] }
        end
      end
    else
      # trying to change the password
      correct_pass = @user.valid_password?(params[:current_password])

      if correct_pass && @user.update_attributes(user_params)
        if params[:remove_image] == "1"
          @user.image = nil
        end
        @user.save
        sign_in(@user, :bypass => true)
        respond_to do |format|
          format.html { redirect_to root_url, notice: "Account updated!" }
        end
      else
        respond_to do |format|
          if correct_pass
            u = User.find(@user.id)
            sign_in(u, :bypass => true)
            format.html { redirect_to edit_user_path(@user), notice: @user.errors.to_a[0] }
          else
            sign_in(@user, :bypass => true)
            format.html { redirect_to edit_user_path(@user), notice: "Incorrect current password" }
          end
        end
      end
    end
  end
    
  # GET /users/:id/details [.json]
  def details
    user = User.find(params[:id])
    @details = user.details_json
    render json: @details 
  end

  # PUT /user/updatemetacodes
  def updatemetacodes
    metacode_set = params[:metacodes][:value]
    @user.settings.metacodes = metacode_set.split(',')
    
    @user.save

    respond_to do |format|
      format.json { render json: @user }
    end
  end

  private

  def set_user
    @user = current_user
  end

  def find_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email, :image, :password, :password_confirmation)
  end
end
