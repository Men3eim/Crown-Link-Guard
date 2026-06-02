class DomainMatcher
  TRUSTED_DOMAINS = %w[
    booking.com admin.booking.com eviivo.com expediapartnercentral.com hotels.com
    expedia.com zoho.com zohodesk.com crownbs.com
  ].freeze

  def initialize(domain)
    @domain = domain.to_s.downcase.sub(/\Awww\./, "")
  end

  def allowlist_match
    AllowlistedDomain.active.find_each.find { |entry| exact_or_allowed_subdomain?(entry.domain, entry.allow_subdomains) }
  end

  def blocklist_match
    BlockedDomain.active.find_each.find { |entry| exact_or_subdomain?(entry.domain) }
  end

  def fake_trusted_domain_trick?
    TRUSTED_DOMAINS.any? do |trusted|
      @domain.include?("#{trusted}.") && !exact_or_subdomain?(trusted)
    end
  end

  def resembles_trusted_domain?
    TRUSTED_DOMAINS.any? do |trusted|
      brand = trusted.split(".").first
      next false if exact_or_subdomain?(trusted)

      @domain.include?(brand) || @domain.delete("-").include?(brand)
    end
  end

  def root_domain
    UrlNormalizer.root_domain_for(@domain)
  end

  private

  def exact_or_allowed_subdomain?(trusted_domain, allow_subdomains)
    @domain == trusted_domain || (allow_subdomains && @domain.end_with?(".#{trusted_domain}"))
  end

  def exact_or_subdomain?(trusted_domain)
    @domain == trusted_domain || @domain.end_with?(".#{trusted_domain}")
  end
end
