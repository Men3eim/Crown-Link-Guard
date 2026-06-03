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
    apply_review_feedback!(@report)
    audit!("report_status_updated", @report, status: @report.status)
    redirect_to admin_reports_path, notice: "Report updated."
  end

  def allow_domain
    report = AgentReport.find(params[:id])
    return redirect_to admin_reports_path, alert: "This report has no domain to allow." if report.domain.blank?

    domain = AllowlistedDomain.find_or_initialize_by(domain: report.domain)
    domain.assign_attributes(
      allow_subdomains: false,
      notes: domain.notes.presence || "Added from report ##{report.id}",
      created_by: domain.created_by.presence || current_user.email,
      active: true
    )
    domain.save!
    disabled_blocks = BlockedDomain.where(domain: report.domain, active: true).update_all(active: false, updated_at: Time.current)

    audit!("allowlisted_domain_from_report", domain, report_id: report.id)
    redirect_to admin_reports_path, notice: "#{report.domain} is now trusted. #{disabled_blocks} conflicting blocklist entry disabled."
  end

  def block_domain
    report = AgentReport.find(params[:id])
    return redirect_to admin_reports_path, alert: "This report has no domain to block." if report.domain.blank?

    domain = BlockedDomain.find_or_initialize_by(domain: report.domain)
    domain.assign_attributes(
      severity: domain.severity.presence || "critical",
      reason: domain.reason.presence || "Added from report ##{report.id}",
      created_by: domain.created_by.presence || current_user.email,
      active: true
    )
    domain.save!
    disabled_allows = AllowlistedDomain.where(domain: report.domain, active: true).update_all(active: false, updated_at: Time.current)

    audit!("blocked_domain_from_report", domain, report_id: report.id)
    redirect_to admin_reports_path, notice: "#{report.domain} is now blocked. #{disabled_allows} conflicting allowlist entry disabled."
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

  def apply_review_feedback!(report)
    return if report.domain.blank?

    case report.status
    when "safe"
      entry = AllowlistedDomain.find_or_initialize_by(domain: report.domain)
      entry.assign_attributes(
        allow_subdomains: false,
        notes: entry.notes.presence || "Auto-trusted after report ##{report.id} was reviewed as safe",
        created_by: entry.created_by.presence || current_user.email,
        active: true
      )
      entry.save!
      BlockedDomain.where(domain: report.domain, active: true).update_all(active: false, updated_at: Time.current)
      audit!("report_feedback_allowlisted_domain", entry, report_id: report.id)
    when "phishing"
      entry = BlockedDomain.find_or_initialize_by(domain: report.domain)
      entry.assign_attributes(
        severity: entry.severity.presence || "critical",
        reason: entry.reason.presence || "Auto-blocked after report ##{report.id} was confirmed phishing",
        created_by: entry.created_by.presence || current_user.email,
        active: true
      )
      entry.save!
      AllowlistedDomain.where(domain: report.domain, active: true).update_all(active: false, updated_at: Time.current)
      audit!("report_feedback_blocked_domain", entry, report_id: report.id)
    end
  end
end
