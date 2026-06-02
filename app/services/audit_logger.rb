class AuditLogger
  def self.call(user_email:, action:, record: nil, metadata: {})
    AuditLog.create!(
      user_email: user_email,
      action: action,
      record_type: record&.class&.name,
      record_id: record&.id,
      metadata: metadata || {}
    )
  end
end
