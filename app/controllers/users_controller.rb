class UsersController < ApplicationController
  skip_before_filter :login_required, only: [:new, :create]
  layout 'center', only: [:new, :create]

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params
    if @user.save
      msg = !@user.is_admin ? ' Pending approval by System Administrator' : ''
      flash[:success] = 'Yeah! Signed up successfully.' + msg
      redirect_to login_path
    else
      flash.now[:error] = 'Ooppps! Failed to signup'
      render :new
    end
  end

  def edit
    @user = find_user
  end

  def update
    @user = find_user
    if @user.update_attributes user_params
      flash[:success] = "#{@user.name} Profile updated successfully. Will be reflect next login."
      redirect_to root_path
    else
      flash.now[:error] = "Failed to updated User Profile."
      render :edit
    end
  end

private

  def find_user
    if current_user.id == params[:id].to_i || current_user.is_admin
      return User.find params[:id]
    else
      flash.now[:error] = 'Access denied!'
      redirect_to root_path
    end
  end

  def user_params
    if (current_user and !current_user.is_admin) or !current_user
      params.require(:user).permit(:username, :name, :password, :password_confirmation)
    else
      params.require(:user).permit(:username, :name, :password, :password_confirmation, :status, :is_admin, :is_manager)
    end
  end

end
