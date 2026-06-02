class Admin::DashboardController < Admin::BaseController
  def index
    today = UrlScan.today
    @stats = {
      total_today: today.count,
      blocked_today: today.where(risk_level: "blocked").count,
      high_risk_today: today.where(risk_level: "high_risk").count,
      medium_risk_today: today.where(risk_level: "medium_risk").count,
      pending_reports: AgentReport.pending.count,
      phishing_reports: AgentReport.where(status: "phishing").count
    }
    @top_suspicious_domains = UrlScan.where(risk_level: %w[medium_risk high_risk blocked]).where.not(domain: nil).group(:domain).order(Arel.sql("count_id desc")).limit(8).count(:id)
    @recent_scans = UrlScan.recent.limit(10)
    @recent_reports = AgentReport.recent.limit(10)
  end
end
