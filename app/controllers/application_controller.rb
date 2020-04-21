class ApplicationController < ActionController::Base
  has_mobile_fu  #has_mobile_fu false #-> if you do not want to set the format to :mobile
  before_action :set_mobile_device 
  protect_from_forgery with: :exception
  helper_method :current_user, :logged_in?

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def logged_in?
    !!current_user
  end

  def require_user
    if !logged_in?
      flash[:danger] = "You must be logged in to perform that action"
      redirect_to login_path
    end
  end

  def set_mobile_device
    session[:mobile_device] = false

    #force_mobile_format   #-> if you want to force mobile format
    #session[:mobile_device] = true

  end

end

