class SessionsController < ApplicationController
  def new
    @user = User.new
  end

  def create
    if user = User.authenticate_by(email: params[:user][:email], password: params[:user][:password])
      login user
      log_access(:login, user:)
      redirect_to home_path, notice: "You have signed succesfully"
    else
      log_access(:login_failed, user: nil)
      @user = User.new
      flash[:alert] = "Invalid email / password"
      render :new, status: :unprocessable_content
    end
  end

  def destroy
    log_access(:logout) if current_user
    logout(current_user)
    redirect_to root_path, notice: "You have been logged out"
  end
end
