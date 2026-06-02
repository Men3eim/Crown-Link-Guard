admin_email = ENV.fetch("CROWN_LINK_GUARD_ADMIN_EMAIL", "admin@crownbs.com")
admin_password = ENV.fetch("CROWN_LINK_GUARD_ADMIN_PASSWORD", "ChangeMe123!")
api_token = ENV.fetch("CROWN_LINK_GUARD_API_TOKEN", "dev-extension-token-change-me")

User.find_or_create_by!(email: admin_email) do |user|
  user.name = "Crown Link Guard Admin"
  user.role = "admin"
  user.password = admin_password
  user.password_confirmation = admin_password
  user.active = true
end

[
  ["zoho.com", true],
  ["zohodesk.com", true],
  ["crownbs.com", true],
  ["booking.com", true],
  ["admin.booking.com", false],
  ["eviivo.com", true],
  ["expediapartnercentral.com", true],
  ["hotels.com", true],
  ["expedia.com", true]
].each do |domain, allow_subdomains|
  AllowlistedDomain.find_or_create_by!(domain: domain) do |entry|
    entry.allow_subdomains = allow_subdomains
    entry.notes = "Seeded trusted domain from PRD"
    entry.created_by = admin_email
    entry.active = true
  end
end

SecuritySetting::DEFAULTS.merge("api_token" => api_token).each do |key, value|
  setting = SecuritySetting.find_or_initialize_by(key: key)
  setting.value ||= value
  setting.updated_by ||= admin_email
  setting.save!
end

puts "Seeded Crown Link Guard admin: #{admin_email}"
puts "Default admin password comes from CROWN_LINK_GUARD_ADMIN_PASSWORD or ChangeMe123!"
puts "Extension API token comes from CROWN_LINK_GUARD_API_TOKEN or dev-extension-token-change-me"
