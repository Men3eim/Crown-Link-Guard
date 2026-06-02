class BlockedDomain < ApplicationRecord
  SEVERITIES = %w[low medium high critical].freeze

  before_validation :normalize_domain

  validates :domain, presence: true, uniqueness: true
  validates :severity, inclusion: { in: SEVERITIES }

  scope :active, -> { where(active: true) }

  private

  def normalize_domain
    self.domain = domain.to_s.strip.downcase.sub(/\Awww\./, "")
  end
end
