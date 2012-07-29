class UsersController < ApplicationController
  skip_before_filter :login_required, only: [:new, :create]
  layout 'center', only: [:new, :create]

  def new
    @user = User.new
  end

  def create
    @user = User.new params[:user]
    if @user.save
      redirect_to login_path, success: 'Yeah! Signed up successfully. Pending approval by System Administrator'
    else
      flash.now[:error] = 'Ooppps! Failed to signup'
      render :new
    end
  end
end
