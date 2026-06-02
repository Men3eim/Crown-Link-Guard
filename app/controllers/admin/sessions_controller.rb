class Admin::SessionsController < ApplicationController
  def new
    redirect_to admin_root_path if current_user&.admin?
  end

  def create
    user = User.active.find_by(email: params[:email].to_s.strip.downcase)

    if user&.admin? && user.authenticate(params[:password])
      session[:user_id] = user.id
      user.update!(last_login_at: Time.current)
      AuditLogger.call(user_email: user.email, action: "admin_login", record: user)
      redirect_to admin_root_path
    else
      flash.now[:alert] = "Invalid admin email or password."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    AuditLogger.call(user_email: current_user.email, action: "admin_logout", record: current_user) if current_user
    reset_session
    redirect_to admin_login_path
  end
end
