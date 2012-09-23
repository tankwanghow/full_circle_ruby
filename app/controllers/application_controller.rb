class ApplicationController < ActionController::Base
  include Authentication
  include SentientController

  protect_from_forgery
  before_filter :login_required

  # rescue_from Exception do |e|
  #   msg = "#{e.class.name}"
  #   msg += "<br/>#{e.message}"
  #   flash[:error] = msg.html_safe
  #   redirect_to exception_redirection_path
  # end

private

  def store_param name
    if params[name]
      params[name].each do |k,v|
        session[name.to_sym][k.to_sym] = v.blank? ? nil : v
      end
    else
      session[name.to_sym] ||= {}
    end
  end

  def exception_redirection_path
    if !request.env['HTTP_REFERER'].blank?
      :back
    else
      # if params
      #   if params[:action] == 'update'
      #     { controller: params[:controller], id: params[:id], action: 'edit' }
      #   elsif params[:action] == 'create'
      #     { controller: params[:controller], action: 'new' }
      #   end
      # else
        root_path
      # end
    end
  end

end