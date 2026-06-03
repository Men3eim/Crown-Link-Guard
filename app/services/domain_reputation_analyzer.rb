class DomainReputationAnalyzer
  Result = Struct.new(:score, :reasons, keyword_init: true)

  FREE_HOSTING_DOMAINS = %w[github.io pages.dev netlify.app vercel.app web.app firebaseapp.com workers.dev].freeze
  DYNAMIC_DNS_DOMAINS = %w[duckdns.org ddns.net hopto.org no-ip.org serveo.net].freeze

  def self.call(domain)
    new(domain).call
  end

  def initialize(domain)
    @domain = domain.to_s.downcase.sub(/\Awww\./, "")
  end

  def call
    score = 0
    reasons = []

    if FREE_HOSTING_DOMAINS.any? { |suffix| @domain == suffix || @domain.end_with?(".#{suffix}") }
      score += 15
      reasons << "Domain is hosted on a free publishing platform; verify login/payment pages carefully"
    end

    if DYNAMIC_DNS_DOMAINS.any? { |suffix| @domain == suffix || @domain.end_with?(".#{suffix}") }
      score += 30
      reasons << "Domain uses dynamic DNS infrastructure, which is common in phishing and malware campaigns"
    end

    Result.new(score: score, reasons: reasons)
  end
end
