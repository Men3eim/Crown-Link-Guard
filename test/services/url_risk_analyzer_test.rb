require "test_helper"

class UrlRiskAnalyzerTest < ActiveSupport::TestCase
  setup do
    AllowlistedDomain.delete_all
    BlockedDomain.delete_all
    SecuritySetting.delete_all

    SecuritySetting::DEFAULTS.each { |key, value| SecuritySetting.create!(key: key, value: value) }
    AllowlistedDomain.create!(domain: "booking.com", allow_subdomains: true, active: true)
    AllowlistedDomain.create!(domain: "eviivo.com", allow_subdomains: true, active: true)
    BlockedDomain.create!(domain: "known-phishing.test", severity: "critical", active: true)
  end

  test "official booking domain is safe" do
    result = UrlRiskAnalyzer.call("https://admin.booking.com")

    assert_equal "safe", result[:risk_level]
    assert_operator result[:risk_score], :<=, 30
    assert_includes result[:reasons], "Official allowlisted domain"
  end

  test "fake booking payment domain is blocked" do
    result = UrlRiskAnalyzer.call("https://booking-secure-payment.com/login")

    assert_equal "blocked", result[:risk_level]
    assert_operator result[:risk_score], :>=, 81
    assert result[:reasons].any? { |reason| reason.include?("not official") }
  end

  test "booking suffix trick is blocked" do
    result = UrlRiskAnalyzer.call("https://booking.com.fake-domain.net/login")

    assert_equal "blocked", result[:risk_level]
    assert result[:reasons].any? { |reason| reason.include?("subdomain trick") }
  end

  test "url shortener with payment wording is blocked" do
    result = UrlRiskAnalyzer.call("http://bit.ly/payment-confirmation")

    assert_equal "blocked", result[:risk_level]
    assert result[:reasons].any? { |reason| reason.include?("URL shortener") }
  end

  test "blocklisted domain is blocked" do
    result = UrlRiskAnalyzer.call("https://known-phishing.test/path")

    assert_equal "blocked", result[:risk_level]
    assert result[:reasons].any? { |reason| reason.include?("blocklist") }
  end

  test "executable download from unknown domain is blocked" do
    result = UrlRiskAnalyzer.call("https://files-example.net/update.exe")

    assert_equal "blocked", result[:risk_level]
    assert result[:reasons].any? { |reason| reason.include?("executable") }
  end

  test "at sign destination trick is high risk or blocked" do
    result = UrlRiskAnalyzer.call("https://booking.com@fake-domain.net/login")

    assert_includes %w[high_risk blocked], result[:risk_level]
    assert result[:reasons].any? { |reason| reason.include?("@ sign") }
  end

  test "encoded redirect parameter increases risk" do
    result = UrlRiskAnalyzer.call("https://unknown-example.net/login?redirect=https%3A%2F%2Ffake-payments.example")

    assert_includes %w[high_risk blocked], result[:risk_level]
    assert result[:reasons].any? { |reason| reason.include?("redirect parameter") }
  end
end
