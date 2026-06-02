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
end
