require "test_helper"

class AdminDashboardTest < ActionDispatch::IntegrationTest
  setup do
    User.delete_all
    UrlScan.delete_all
    AgentReport.delete_all
    AllowlistedDomain.delete_all
    BlockedDomain.delete_all
    SecuritySetting.delete_all

    @admin = User.create!(
      name: "Admin",
      email: "admin@crownbs.com",
      role: "admin",
      password: "ChangeMe123!",
      password_confirmation: "ChangeMe123!",
      active: true
    )
  end

  test "admin can log in and view dashboard pages" do
    post admin_login_path, params: { email: @admin.email, password: "ChangeMe123!" }
    assert_redirected_to admin_root_path

    get admin_root_path
    assert_response :success
    assert_includes response.body, "Dashboard"

    get admin_settings_path
    assert_response :success
    assert_includes response.body, "Settings"
  end

  test "allowing a scanned domain disables conflicting blocklist entry" do
    login_as_admin
    scan = UrlScan.create!(original_url: "https://example.test", normalized_url: "https://example.test", domain: "example.test", risk_score: 90, risk_level: "blocked", action_taken: "blocked")
    BlockedDomain.create!(domain: "example.test", severity: "critical", active: true)

    post allow_domain_admin_url_scan_path(scan)

    assert_redirected_to admin_url_scans_path
    assert AllowlistedDomain.find_by(domain: "example.test").active?
    assert_not BlockedDomain.find_by(domain: "example.test").active?
  end

  test "blocking a scanned domain disables conflicting allowlist entry" do
    login_as_admin
    scan = UrlScan.create!(original_url: "https://example.test", normalized_url: "https://example.test", domain: "example.test", risk_score: 5, risk_level: "safe", action_taken: "allowed")
    AllowlistedDomain.create!(domain: "example.test", allow_subdomains: false, active: true)

    post block_domain_admin_url_scan_path(scan)

    assert_redirected_to admin_url_scans_path
    assert BlockedDomain.find_by(domain: "example.test").active?
    assert_not AllowlistedDomain.find_by(domain: "example.test").active?
  end

  private

  def login_as_admin
    post admin_login_path, params: { email: @admin.email, password: "ChangeMe123!" }
    follow_redirect!
  end
end
