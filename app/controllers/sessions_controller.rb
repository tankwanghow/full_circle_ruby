class SessionsController < ApplicationController
  layout "center"
  skip_before_filter :login_required

  def new
    if logged_in?
      redirect_to :back, notice: "Already logged in!"
    end
  end

  def create
    @user = User.find_by_username params[:session][:username]
    if @user && @user.authenticate(params[:session][:password])
      if @user.aasm_read_state == :active
        session[:user_id] = @user.id
        flash[:success] = "Logged in successfully."
        redirect_to_target_or_default '/'
      else
        flash[:notice] = "Account is #{@user.aasm_read_state.to_s.capitalize}."
        render :new
      end
    else
      flash.now[:error] = "Invalid username or password!"
      render :new
    end
  end

  def destroy
    if logged_in?
      session.clear
      flash[:success] = "You have been logged out."
    else
      flash.now[:error] = "Not log in, cannot logout."
    end
    redirect_to login_url
  end
end
