class KomUsersController < ApplicationController
  before_action :require_user
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :require_same_user, only: [:edit, :update, :destroy]
  before_action :require_admin, only: [:new, :create, :destroy]
  
  def index
    @users = Kom_User.all
  end

  def new
    @user = Kom_User.new
  end
  
  def create
    @user = Kom_User.new(user_params)
    if @user.save
      flash[:success] = "#{@user.U_USERNAME} felhasználó sikeresen létrehozva!"
      redirect_to root_path
    else
      flash[:danger] = "Sikertelen regisztráció!"
      render 'new'
    end
  end

  def show
  end

  def edit
  end

  def update
    if @user.update(user_params)
      flash[:success] = "Sikeres módosítás!"
      redirect_to kom_user_path(@user)
    else
      render 'edit'
    end
  end

  def destroy
    #@user.destroy
    #flash[:danger] = "Sikeres felhasználó törlés!"
    flash[:danger] = "Figyelem! Felhasználó törlése nem lehetséges, mivel ez a fiók már használatban volt!"
    redirect_to kom_users_path
  end

  private
  
  def set_user
    @user = Kom_User.find(params[:id])
  end

  def user_params
    params.require(:kom_user).permit(:U_USERNAME, :U_EMAIL, :password, :U_ADMIN, :U_ROLES)
  end

  def require_same_user
    if current_user != @user and !current_user.admin?
      flash[:danger] = "You and admin users can only edit your own account" 
      redirect_to root_path
    end
  end

  def require_admin
    if logged_in? and !current_user.admin?
      flash[:danger] = "Only admin users can perform that action"
      redirect_to root_path
    end
  end

end