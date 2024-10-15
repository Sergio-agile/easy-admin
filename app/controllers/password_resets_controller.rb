class PasswordResetsController < ApplicationController
  before_action :set_user_by_token, only: [:edit, :update]

  def new
    @user = User.new
  end

  def create
    if user = User.find_by(email: params[:user][:email])
      PasswordMailer.with(
        user: user,
        token: user.generate_token_for(:password_reset)
      ).password_reset.deliver_later
    end

    redirect_to root_path, notice: 'Check your email to reset your password'
  end

  def edit

  end

  def update
    if @user.update(password_params)
      redirect_to home_path, notice: 'Your password have been reset succesfully'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user_by_token
    @user = User.find_by_token_for(:password_reset, params[:token])
    redirect_to new_password_resets_path, alert: 'Invalid token, please request a new one' unless @user.present?
  end

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end

end
