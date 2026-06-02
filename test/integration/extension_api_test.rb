require "test_helper"

class ExtensionApiTest < ActionDispatch::IntegrationTest
  setup do
    UrlScan.delete_all
    AgentReport.delete_all
    AllowlistedDomain.delete_all
    BlockedDomain.delete_all
    SecuritySetting.delete_all

    SecuritySetting::DEFAULTS.merge("api_token" => "test-token").each do |key, value|
      SecuritySetting.create!(key: key, value: value)
    end
    AllowlistedDomain.create!(domain: "booking.com", allow_subdomains: true, active: true)
  end

  test "scan url requires token" do
    post api_v1_scan_url_path, params: { url: "https://admin.booking.com" }, as: :json

    assert_response :unauthorized
  end

  test "scan url logs blocked result" do
    post api_v1_scan_url_path,
      params: { url: "https://booking-secure-payment.com/login", ticket_id: "123", agent_email: "agent@crownbs.com" },
      headers: { "Authorization" => "Bearer test-token" },
      as: :json

    assert_response :success
    body = JSON.parse(response.body)
    assert_equal "blocked", body["risk_level"]
    assert_equal 1, UrlScan.count
  end

  test "agent report is saved" do
    post api_v1_reports_path,
      params: { url: "https://booking.com.fake-domain.net/login", ticket_id: "123", agent_email: "agent@crownbs.com" },
      headers: { "Authorization" => "Bearer test-token" },
      as: :json

    assert_response :success
    assert_equal 1, AgentReport.count
    assert_equal "pending", AgentReport.first.status
  end
end
