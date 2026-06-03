require "csv"

class Admin::UrlScansController < Admin::BaseController
  def index
    @url_scans = filtered_scans.recent.limit(500)

    respond_to do |format|
      format.html
      format.csv { send_data csv_for(@url_scans), filename: "crown-link-guard-url-scans-#{Date.current}.csv" }
    end
  end

  def show
    @url_scan = UrlScan.find(params[:id])
  end

  def allow_domain
    scan = UrlScan.find(params[:id])
    return redirect_to admin_url_scans_path, alert: "This scan has no domain to allow." if scan.domain.blank?

    domain = AllowlistedDomain.find_or_initialize_by(domain: scan.domain)
    domain.assign_attributes(
      allow_subdomains: false,
      notes: domain.notes.presence || "Added from scan ##{scan.id}",
      created_by: domain.created_by.presence || current_user.email,
      active: true
    )
    domain.save!
    disabled_blocks = BlockedDomain.where(domain: scan.domain, active: true).update_all(active: false, updated_at: Time.current)

    audit!("allowlisted_domain_from_scan", domain, scan_id: scan.id)
    redirect_to admin_url_scans_path, notice: "#{scan.domain} is now trusted. #{disabled_blocks} conflicting blocklist entry disabled."
  end

  def block_domain
    scan = UrlScan.find(params[:id])
    return redirect_to admin_url_scans_path, alert: "This scan has no domain to block." if scan.domain.blank?

    domain = BlockedDomain.find_or_initialize_by(domain: scan.domain)
    domain.assign_attributes(
      severity: domain.severity.presence || "high",
      reason: domain.reason.presence || "Added from scan ##{scan.id}",
      created_by: domain.created_by.presence || current_user.email,
      active: true
    )
    domain.save!
    disabled_allows = AllowlistedDomain.where(domain: scan.domain, active: true).update_all(active: false, updated_at: Time.current)

    audit!("blocked_domain_from_scan", domain, scan_id: scan.id)
    redirect_to admin_url_scans_path, notice: "#{scan.domain} is now blocked. #{disabled_allows} conflicting allowlist entry disabled."
  end

  private

  def filtered_scans
    scans = UrlScan.all
    scans = scans.where(agent_email: params[:agent_email]) if params[:agent_email].present?
    scans = scans.where(domain: params[:domain]) if params[:domain].present?
    scans = scans.where(risk_level: params[:risk_level]) if params[:risk_level].present?
    scans = scans.where(action_taken: params[:action_taken]) if params[:action_taken].present?
    scans
  end

  def csv_for(scans)
    CSV.generate(headers: true) do |csv|
      csv << ["Date/time", "Agent email", "URL", "Domain", "Risk score", "Risk level", "Action taken", "Ticket URL", "Reasons"]
      scans.find_each do |scan|
        csv << [scan.created_at, scan.agent_email, scan.normalized_url || scan.original_url, scan.domain, scan.risk_score, scan.risk_level, scan.action_taken, scan.ticket_url, Array(scan.reasons).join("; ")]
      end
    end
  end
end
