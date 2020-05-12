class SessionsController < ApplicationController
  before_action :logged_in_redirect, only: [:new, :create]
  #protect_from_forgery with: :null_session
  skip_before_action :verify_authenticity_token, :except => [:create] 


  def new
  end

  def create
    puts params[:session][:username]
    user = Kom_User.find_by(username: params[:session][:username])
    if user && user.authenticate(params[:session][:password])
      session[:user_id] = user.id
      flash[:success] = "Sikeres bejelentkezés!"
      #redirect_to user_path(user)
      redirect_to root_path
    else
      flash.now[:error] = "Hibás bejelentkezési adatok!"
      render 'new'
    end
  end


  def destroy
    session[:user_id] = nil
    flash[:success] = "Sikeres kijelentkezés!"
    redirect_to login_path
  end

  private

  def logged_in_redirect
    if logged_in?
      flash[:error] = "Ön már korábban bejelentkezett!"
      redirect_to root_path
    end
  end
  

end