class SecuritySetting < ApplicationRecord
  validates :key, presence: true, uniqueness: true

  DEFAULTS = {
    "medium_risk_threshold" => "31",
    "high_risk_threshold" => "61",
    "blocked_threshold" => "81",
    "allow_continue_on_medium" => "true",
    "allow_continue_on_high" => "false",
    "ahmed_contact_email" => "ahmed.moniem@crownbs.com",
    "team_leader_instructions" => "Please ask your Team Leader before opening this link. Keep the ticket open and do not click until verified.",
    "internal_system_name" => "Crown Link Guard",
    "extension_allowed_version" => "1.0.0",
    "enable_brand_impersonation" => "true",
    "enable_domain_reputation" => "true",
    "enable_redirect_scanning" => "true",
    "scan_redirects_for_all_links" => "false",
    "enable_threat_intelligence" => "true",
    "google_safe_browsing_api_key" => "",
    "virustotal_api_key" => ""
  }.freeze

  def self.fetch_value(key)
    find_by(key: key)&.value || DEFAULTS[key]
  end

  def self.boolean(key)
    ActiveModel::Type::Boolean.new.cast(fetch_value(key))
  end

  def self.integer(key)
    fetch_value(key).to_i
  end
end
