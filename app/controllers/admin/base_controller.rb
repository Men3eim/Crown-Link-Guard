class Admin::BaseController < ApplicationController
  before_action :require_admin
  layout "application"

  private

  def audit!(action, record = nil, metadata = {})
    AuditLogger.call(user_email: current_user.email, action: action, record: record, metadata: metadata)
  end
end
