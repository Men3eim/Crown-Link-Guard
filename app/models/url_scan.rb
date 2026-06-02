class UrlScan < ApplicationRecord
  RISK_LEVELS = %w[safe medium_risk high_risk blocked].freeze
  ACTIONS = %w[allowed warned blocked reported cancelled asked_team_leader asked_senior_agent copied_details].freeze

  validates :risk_level, inclusion: { in: RISK_LEVELS }
  validates :action_taken, inclusion: { in: ACTIONS }
  validates :risk_score, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }

  scope :recent, -> { order(created_at: :desc) }
  scope :today, -> { where(created_at: Time.zone.now.beginning_of_day..) }
end
