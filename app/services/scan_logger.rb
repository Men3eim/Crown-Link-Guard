class ScanLogger
  def self.call(analysis, metadata = {})
    action_taken = case analysis[:action]
                   when "allow" then "allowed"
                   when "warn" then "warned"
                   else "blocked"
                   end

    UrlScan.create!(
      original_url: analysis[:original_url],
      normalized_url: analysis[:normalized_url],
      domain: analysis[:domain],
      risk_score: analysis[:risk_score],
      risk_level: analysis[:risk_level],
      action_taken: action_taken,
      reasons: analysis[:reasons],
      agent_email: metadata[:agent_email],
      agent_name: metadata[:agent_name],
      ticket_url: metadata[:ticket_url],
      ticket_id: metadata[:ticket_id],
      user_agent: metadata[:user_agent],
      device_name: metadata[:device_name],
      source: metadata[:source].presence || "zoho-desk-extension"
    )
  end
end
