class AuditLog < ApplicationRecord
  validates :action, presence: true

  scope :recent, -> { order(created_at: :desc) }
end
