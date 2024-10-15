class ApplicationController < ActionController::Base
  include Pagy::Backend

  def sidemenu_active(key)
    @sidemenu_active = key
  end

  private

  helper_method :current_user_signed_in?
  helper_method :current_user

  def authenticate_user!
    redirect_to root_path, alert: 'You must be logged in' unless current_user_signed_in?
  end

  def current_user
    Current.user ||= autheticate_user_from_session
  end

  def autheticate_user_from_session
    session[:user_id] && user = User.find_by(id: session[:user_id])
  end

  def current_user_signed_in?
    current_user.present?
  end

  def login(user)
    Current.user = user
    reset_session
    session[:user_id] = user.id
  end

  def logout(user)
    Current.user = nil
    reset_session
  end
end
