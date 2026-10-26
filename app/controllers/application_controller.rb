class ApplicationController < ActionController::Base
  SESSION_IDLE_TIMEOUT = 2.hours

  before_action :expire_idle_session

  def sidemenu_active(key)
    @sidemenu_active = key
  end

  private

  helper_method :current_user_signed_in?
  helper_method :current_user

  def authenticate_user!
    redirect_to root_path, alert: "You must be logged in" unless current_user_signed_in?
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
    session[:last_seen_at] = Time.current.to_i
  end

  def expire_idle_session
    return unless session[:user_id]

    if session[:last_seen_at].to_i < SESSION_IDLE_TIMEOUT.ago.to_i
      logout(current_user)
      redirect_to root_path, alert: "Your session has expired, please log in again"
    else
      session[:last_seen_at] = Time.current.to_i
    end
  end

  def logout(user)
    Current.user = nil
    reset_session
  end
end
