class Admin::AuditLogsController < Admin::BaseController
  def index
    @audit_logs = AuditLog.recent.limit(500)
  end
end
