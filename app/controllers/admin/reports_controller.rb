require "csv"

class Admin::ReportsController < Admin::BaseController
  def index
    @reports = filtered_reports.recent.limit(500)

    respond_to do |format|
      format.html
      format.csv { send_data csv_for(@reports), filename: "crown-link-guard-reports-#{Date.current}.csv" }
    end
  end

  def show
    @report = AgentReport.find(params[:id])
  end

  def update
    @report = AgentReport.find(params[:id])
    @report.update!(
      status: report_params[:status],
      reviewer_note: report_params[:reviewer_note],
      reviewer_email: current_user.email,
      reviewed_at: Time.current
    )
    audit!("report_status_updated", @report, status: @report.status)
    redirect_to admin_reports_path, notice: "Report updated."
  end

  def allow_domain
    report = AgentReport.find(params[:id])
    domain = AllowlistedDomain.find_or_create_by!(domain: report.domain) do |entry|
      entry.allow_subdomains = false
      entry.notes = "Added from report ##{report.id}"
      entry.created_by = current_user.email
      entry.active = true
    end
    audit!("allowlisted_domain_from_report", domain, report_id: report.id)
    redirect_to admin_reports_path, notice: "#{report.domain} added to allowlist."
  end

  def block_domain
    report = AgentReport.find(params[:id])
    domain = BlockedDomain.find_or_create_by!(domain: report.domain) do |entry|
      entry.severity = "critical"
      entry.reason = "Added from report ##{report.id}"
      entry.created_by = current_user.email
      entry.active = true
    end
    audit!("blocked_domain_from_report", domain, report_id: report.id)
    redirect_to admin_reports_path, notice: "#{report.domain} added to blocklist."
  end

  private

  def filtered_reports
    reports = AgentReport.all
    reports = reports.where(status: params[:status]) if params[:status].present?
    reports = reports.where(domain: params[:domain]) if params[:domain].present?
    reports = reports.where(agent_email: params[:agent_email]) if params[:agent_email].present?
    reports
  end

  def report_params
    params.require(:agent_report).permit(:status, :reviewer_note)
  end

  def csv_for(reports)
    CSV.generate(headers: true) do |csv|
      csv << ["Date/time", "Agent", "URL", "Domain", "Ticket URL", "Risk level", "Status", "Reviewer", "Notes"]
      reports.find_each do |report|
        csv << [report.created_at, report.agent_email, report.normalized_url || report.original_url, report.domain, report.ticket_url, report.risk_level, report.status, report.reviewer_email, report.reviewer_note]
      end
    end
  end
end
