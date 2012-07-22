class SessionsController < ApplicationController
  layout "center"
  skip_before_filter :login_required

  def new
    if logged_in?
      flash[:notice] = "Already logged in!"
      redirect_back_ot_to '/'
    end
  end

  def create
    @user = login params[:username], params[:password]
    if @user && @user.aasm_current_state == :active
      session[:user_id] = @user.id
      flash[:success] = "Logged in successfully."
      redirect_to_target_or_default '/'
    elsif @user && @user.status != "active"
      flash[:info] = "Pending Account Activation."
      render :new
    else
      flash[:error] = "Invalid username or password!"
      render :new
    end
  end

  def destroy
    if logged_in?
      session.clear
      flash[:success] = "You have been logged out."
    else
      flash[:error] = "Not log in, cannot logout."
    end
    redirect_to login_url
  end
end
