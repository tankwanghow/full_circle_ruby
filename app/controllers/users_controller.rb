class UsersController < ApplicationController
  skip_before_filter :login_required, only: [:new, :create]
  layout 'center', only: [:new, :create]

  def new
    @user = User.new
  end

  def create
    @user = User.new params[:user]
    if @user.save
      flash[:success] = 'Yeah! Signed up successfully. Pending approval by System Administrator'
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
    if @user.update_attributes params[:user]
      flash[:success] = "User '#{@user.name}' Profile updated successfully. Will be reflect next login."
      redirect_to root_path
    else
      flash[:error] = "Failed to updated User Profile."
      render :edit
    end
 end

private

  def find_user
    if current_user.id == params[:id] || current_user.is_admin
      return User.find params[:id]
    else
      flash[:error] = 'Access denied!'
      redirect_to root_path
    end
  end

end
