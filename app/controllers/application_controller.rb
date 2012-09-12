class ApplicationController < ActionController::Base
  include Authentication
  include SentientController
  include StoreSearchParamsSession

  protect_from_forgery
  before_filter :login_required

  rescue_from Exception do |e|
    msg = "#{e.class.name}"
    msg += "<br/>#{e.message}"
    flash[:error] = msg.html_safe
    redirect_to exception_redirection_path
  end

  private

  def exception_redirection_path
    if params
      if params[:action] == 'update'
        {controller: params[:controller], id: params[:id], action: 'edit'}
      elsif params[:action] == 'create'
        {controller: params[:controller], action: 'new'}
      else
        :back
      end
    else
      :back
    end
  end

end