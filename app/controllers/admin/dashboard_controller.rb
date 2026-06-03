class Admin::DashboardController < Admin::BaseController
  def index
    today = UrlScan.today
    @stats = {
      total_today: today.count,
      blocked_today: today.where(risk_level: "blocked").count,
      high_risk_today: today.where(risk_level: "high_risk").count,
      medium_risk_today: today.where(risk_level: "medium_risk").count,
      safe_today: today.where(risk_level: "safe").count,
      scanned_this_week: UrlScan.where(created_at: 7.days.ago..).count,
      pending_reports: AgentReport.pending.count,
      phishing_reports: AgentReport.where(status: "phishing").count,
      safe_reports: AgentReport.where(status: "safe").count
    }
    @top_suspicious_domains = UrlScan.where(risk_level: %w[medium_risk high_risk blocked]).where.not(domain: nil).group(:domain).order(Arel.sql("count_id desc")).limit(8).count(:id)
    @top_reasons = top_reasons
    @daily_scan_counts = UrlScan.where(created_at: 7.days.ago..).group("DATE(created_at)").order(Arel.sql("DATE(created_at) ASC")).count
    @recent_scans = UrlScan.recent.limit(10)
    @recent_reports = AgentReport.recent.limit(10)
  end

  private

  def top_reasons
    counts = Hash.new(0)
    UrlScan.where(created_at: 30.days.ago..).where(risk_level: %w[medium_risk high_risk blocked]).pluck(:reasons).each do |reasons|
      Array(reasons).each { |reason| counts[reason] += 1 }
    end
    counts.sort_by { |_reason, count| -count }.first(10)
  end
end
