class ApplicationController < ActionController::Base
  include Authentication
  include SentientController

  protect_from_forgery
  before_filter :login_required

  rescue_from Exception do |e|
    msg = "#{e.class.name} -> #{e.message}"
    flash[:error] = msg.html_safe
    redirect_to exception_redirection_path
  end

private

  def admin_lock_check object
    raise 'Need Administrator Right!' if object.admin_lock and !current_user.is_admin?
  end

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
      root_path
    end
  end

end