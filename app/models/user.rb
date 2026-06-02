class User < ApplicationRecord
  ROLES = %w[agent team_leader admin].freeze

  has_secure_password

  before_validation :normalize_email

  validates :name, :email, :role, presence: true
  validates :email, uniqueness: true
  validates :role, inclusion: { in: ROLES }

  scope :active, -> { where(active: true) }

  def admin?
    role == "admin"
  end

  private

  def normalize_email
    self.email = email.to_s.strip.downcase
  end
end
