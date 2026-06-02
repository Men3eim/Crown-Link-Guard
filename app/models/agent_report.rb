class AgentReport < ApplicationRecord
  STATUSES = %w[pending safe phishing needs_more_info].freeze

  validates :status, inclusion: { in: STATUSES }
  validates :risk_level, inclusion: { in: UrlScan::RISK_LEVELS }

  scope :recent, -> { order(created_at: :desc) }
  scope :pending, -> { where(status: "pending") }
end
