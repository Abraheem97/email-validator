class UsersController < ApplicationController

  def index
    @user = User.new
    @users = User.all
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @user.email = EmailValidatorService.new(@user.first_name, @user.last_name, params[:url]).call
    byebug

    if @user.save
      redirect_to action: "index"
    else
      render :new, status: :unprocessable_entity
    end

  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email)
  end
end
