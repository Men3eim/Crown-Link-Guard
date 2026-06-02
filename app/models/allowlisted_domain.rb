class AllowlistedDomain < ApplicationRecord
  before_validation :normalize_domain

  validates :domain, presence: true, uniqueness: true

  scope :active, -> { where(active: true) }

  private

  def normalize_domain
    self.domain = domain.to_s.strip.downcase.sub(/\Awww\./, "")
  end
end
