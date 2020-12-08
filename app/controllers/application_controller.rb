class ApplicationController < ActionController::Base
  has_mobile_fu  #has_mobile_fu false #-> if you do not want to set the format to :mobile
  before_action :set_mobile_device 
  protect_from_forgery with: :exception
  helper_method :current_user, :logged_in?, :current_database

  def current_user
    @current_user ||= Kom_User.find(session[:user_id]) if session[:user_id]
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
    session[:mobile_device] = true if is_mobile_device?
    #force_mobile_format   #-> if you want to force mobile format
    #session[:mobile_device] = true  #-> if you want to force mobile format
  end

  def current_database
    @current_database ||= Rails.configuration.database_configuration[Rails.env]
  end

end

