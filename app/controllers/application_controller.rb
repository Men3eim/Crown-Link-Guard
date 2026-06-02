class ApplicationController < ActionController::Base
  helper_method :current_user

  private

  def current_user
    @current_user ||= User.active.find_by(id: session[:user_id]) if session[:user_id]
  end

  def require_admin
    redirect_to admin_login_path, alert: "Please sign in." unless current_user&.admin?
  end
end
