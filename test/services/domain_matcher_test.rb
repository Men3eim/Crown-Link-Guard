require "test_helper"

class DomainMatcherTest < ActiveSupport::TestCase
  setup do
    AllowlistedDomain.delete_all
    AllowlistedDomain.create!(domain: "booking.com", allow_subdomains: true, active: true)
  end

  test "allows approved subdomain" do
    assert DomainMatcher.new("admin.booking.com").allowlist_match
  end

  test "does not allow fake suffix matching" do
    assert_nil DomainMatcher.new("booking.com.fake-domain.net").allowlist_match
  end
end
