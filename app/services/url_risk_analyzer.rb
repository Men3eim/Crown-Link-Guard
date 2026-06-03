class UrlRiskAnalyzer
  SHORTENERS = %w[bit.ly tinyurl.com cutt.ly t.co shorturl.at].freeze
  SUSPICIOUS_KEYWORDS = %w[payment verify secure login update account reservation billing partner support confirmation invoice password credentials authenticate wallet refund payout].freeze
  SUSPICIOUS_TLDS = %w[xyz top tk info click site online].freeze
  DANGEROUS_FILE_EXTENSIONS = %w[exe scr bat cmd com pif js jse vbs vbe msi ps1 iso img dmg apk jar].freeze
  RISKY_FILE_EXTENSIONS = %w[zip rar 7z gz html htm pdf doc docx xls xlsx].freeze
  REDIRECT_PARAMETERS = %w[url uri redirect redirect_uri return return_url continue next target destination dest].freeze
  VISIBLE_URL_REGEX = %r{(?:https?://)?(?:www\.)?[a-z0-9.-]+\.[a-z]{2,}(?:/[^\s<>"']*)?}i

  def self.call(url, metadata = {})
    new(url, metadata).call
  end

  def initialize(url, metadata = {})
    @url = url
    @metadata = metadata || {}
    @normalizer = UrlNormalizer.call(url)
    @reasons = []
    @score = 0
  end

  def call
    return invalid_result unless @normalizer.valid

    @matcher = DomainMatcher.new(@normalizer.domain)
    apply_domain_rules
    apply_url_rules
    @score = [[@score, 0].max, 100].min

    {
      original_url: @normalizer.original_url,
      normalized_url: @normalizer.normalized_url,
      domain: @normalizer.domain,
      root_domain: @normalizer.root_domain,
      risk_score: @score,
      risk_level: risk_level,
      action: action,
      reasons: @reasons.uniq,
      message: message,
      allow_continue_on_medium: SecuritySetting.boolean("allow_continue_on_medium"),
      allow_continue_on_high: SecuritySetting.boolean("allow_continue_on_high")
    }
  end

  private

  def invalid_result
    {
      original_url: @normalizer.original_url,
      normalized_url: nil,
      domain: nil,
      root_domain: nil,
      risk_score: 90,
      risk_level: "blocked",
      action: "block",
      reasons: ["Invalid or unsupported URL: #{@normalizer.error}"],
      message: "This link has been blocked because it is not a valid web URL.",
      allow_continue_on_medium: SecuritySetting.boolean("allow_continue_on_medium"),
      allow_continue_on_high: SecuritySetting.boolean("allow_continue_on_high")
    }
  end

  def apply_domain_rules
    if (blocked = @matcher.blocklist_match)
      @score += 100
      @reasons << "Domain is on the company blocklist (#{blocked.severity})"
      return
    end

    if (allowed = @matcher.allowlist_match)
      @score += @normalizer.scheme == "https" ? 5 : 15
      @reasons << "Official allowlisted domain"
      @reasons << "Approved subdomain of #{allowed.domain}" if @normalizer.domain != allowed.domain
    else
      @score += browser_wide_source? ? 10 : 20
      @reasons << "Domain is not allowlisted yet"
    end

    if @matcher.fake_trusted_domain_trick?
      @score += 55
      @reasons << "Fake official-domain subdomain trick detected"
    elsif @matcher.resembles_trusted_domain?
      @score += 35
      @reasons << "Domain looks similar to an official Crown or OTA domain but is not official"
    end
  end

  def apply_url_rules
    url_downcase = @normalizer.normalized_url.to_s.downcase
    domain = @normalizer.domain.to_s
    labels = domain.split(".")
    uri = URI.parse(@normalizer.normalized_url)
    apply_link_text_rules

    if SHORTENERS.include?(domain)
      @score += 55
      @reasons << "URL shortener detected; final destination cannot be verified"
    end

    keyword_hits = SUSPICIOUS_KEYWORDS.select { |keyword| url_downcase.include?(keyword) }
    if keyword_hits.any?
      @score += [keyword_hits.length * 12, 36].min
      @reasons << "URL contains #{keyword_hits.join(', ')} keyword indicators"
    end

    if domain.include?("booking") && !domain.end_with?("booking.com")
      @score += 25
      @reasons << "URL contains booking but is not Booking.com"
    end

    if SUSPICIOUS_TLDS.include?(domain.split(".").last)
      @score += 25
      @reasons << "Suspicious top-level domain detected"
    end

    if @normalizer.ip_address
      @score += 35
      @reasons << "URL uses an IP address instead of a normal domain"
    end

    if labels.length > 4
      @score += 15
      @reasons << "Domain has too many subdomains"
    end

    if @normalizer.punycode || url_downcase.match?(/%[0-9a-f]{2}/)
      @score += 20
      @reasons << "URL contains encoded or unusual domain characters"
    end

    if @normalizer.scheme == "http"
      @score += 20
      @reasons << "URL uses HTTP instead of HTTPS"
    end

    if uri.userinfo.present? || @normalizer.normalized_url.include?("@")
      @score += 40
      @reasons << "URL contains an @ sign or embedded credentials, which can hide the real destination"
    end

    if uri.port && ![80, 443].include?(uri.port)
      @score += 15
      @reasons << "URL uses a non-standard network port"
    end

    if @normalizer.normalized_url.length > 180
      @score += 15
      @reasons << "URL is unusually long"
    end

    if domain.count("-") >= 3
      @score += 15
      @reasons << "Domain contains many hyphens, a common impersonation pattern"
    end

    if domain.gsub(/[^0-9]/, "").length >= 6
      @score += 15
      @reasons << "Domain contains many numbers, which can indicate disposable infrastructure"
    end

    file_extension = File.extname(uri.path.to_s).delete(".").downcase
    if DANGEROUS_FILE_EXTENSIONS.include?(file_extension)
      @score += 75
      @reasons << "URL points to a potentially dangerous executable or script file"
    elsif RISKY_FILE_EXTENSIONS.include?(file_extension)
      @score += 15
      @reasons << "URL points to a file download that should be verified before opening"
    end

    if encoded_redirect_parameter?(uri.query.to_s)
      @score += 20
      @reasons << "URL contains a redirect parameter that may hide the final destination"
    end

    if ActiveModel::Type::Boolean.new.cast(@metadata[:hidden_link]) && suspicious_context?
      @score += 10
      @reasons << "Suspicious link is hidden behind an image or button"
    end
  rescue URI::InvalidURIError
    @score += 30
    @reasons << "URL structure is unusual and could not be parsed cleanly"
  end

  def apply_link_text_rules
    link_text = @metadata[:link_text].to_s.strip
    return if link_text.blank?

    visible_domains = link_text.scan(VISIBLE_URL_REGEX).map { |candidate| normalized_visible_domain(candidate) }.compact.uniq
    destination_root = @normalizer.root_domain

    mismatched_domain = visible_domains.find { |visible_domain| visible_domain != destination_root && !@normalizer.domain.end_with?(".#{visible_domain}") }
    if mismatched_domain
      @score += 65
      @reasons << "Visible link text shows #{mismatched_domain}, but the real destination is #{@normalizer.domain}"
    end
  end

  def normalized_visible_domain(candidate)
    normalized = UrlNormalizer.call(candidate.match?(/\Ahttps?:\/\//i) ? candidate : "https://#{candidate}")
    return nil unless normalized.valid && normalized.domain.present?

    normalized.root_domain
  end

  def suspicious_context?
    @score >= SecuritySetting.integer("medium_risk_threshold")
  end

  def browser_wide_source?
    @metadata[:source].to_s == "browser-wide-extension"
  end

  def encoded_redirect_parameter?(query)
    return false if query.blank?

    query.split("&").any? do |pair|
      key, value = pair.split("=", 2)
      next false if key.blank? || value.blank?

      REDIRECT_PARAMETERS.include?(URI.decode_www_form_component(key).downcase) && URI.decode_www_form_component(value).match?(/\Ahttps?:\/\//i)
    rescue ArgumentError
      false
    end
  end

  def risk_level
    return "blocked" if @score >= SecuritySetting.integer("blocked_threshold")
    return "high_risk" if @score >= SecuritySetting.integer("high_risk_threshold")
    return "medium_risk" if @score >= SecuritySetting.integer("medium_risk_threshold")

    "safe"
  end

  def action
    case risk_level
    when "safe" then "allow"
    when "medium_risk", "high_risk" then "warn"
    else "block"
    end
  end

  def message
    case risk_level
    when "safe"
      "This link does not show strong phishing indicators."
    when "medium_risk"
      "Careful - this link may be unsafe. Please verify it before opening."
    when "high_risk"
      "This link looks suspicious. Please verify with a Team Leader, senior agent, or Ahmed Moniem."
    else
      "This link has been blocked because it matches phishing indicators."
    end
  end
end
