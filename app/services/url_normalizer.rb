require "ipaddr"
require "uri"

class UrlNormalizer
  COMMON_SECOND_LEVEL_TLDS = %w[co.com co.uk com.au com.br com.eg com.tr net.au org.uk].freeze

  Result = Struct.new(:original_url, :normalized_url, :domain, :root_domain, :valid, :scheme, :ip_address, :punycode, :error, keyword_init: true) do
    def to_h
      {
        original_url: original_url,
        normalized_url: normalized_url,
        domain: domain,
        root_domain: root_domain,
        valid: valid,
        scheme: scheme,
        ip_address: ip_address,
        punycode: punycode,
        error: error
      }
    end
  end

  def self.call(url)
    new(url).call
  end

  def initialize(url)
    @original_url = url.to_s.strip
  end

  def call
    return invalid("URL is blank") if @original_url.blank?

    candidate = @original_url.match?(/\A[a-z][a-z0-9+\-.]*:/i) ? @original_url : "https://#{@original_url}"
    uri = URI.parse(candidate)
    return invalid("URL must include a host") if uri.host.blank?

    host = uri.host.downcase.sub(/\Awww\./, "")
    uri.host = host
    uri.fragment = nil

    Result.new(
      original_url: @original_url,
      normalized_url: uri.to_s,
      domain: host,
      root_domain: root_domain_for(host),
      valid: %w[http https].include?(uri.scheme),
      scheme: uri.scheme,
      ip_address: ip_address?(host),
      punycode: host.include?("xn--"),
      error: nil
    )
  rescue URI::InvalidURIError => e
    invalid(e.message)
  end

  def self.root_domain_for(host)
    new("").root_domain_for(host)
  end

  def root_domain_for(host)
    labels = host.to_s.downcase.split(".").reject(&:blank?)
    return host if labels.length < 3

    tail_three = labels[-3..].join(".")
    return tail_three if COMMON_SECOND_LEVEL_TLDS.any? { |suffix| tail_three.end_with?(".#{suffix}") }

    labels[-2..].join(".")
  end

  private

  def invalid(error)
    Result.new(original_url: @original_url, normalized_url: nil, domain: nil, root_domain: nil, valid: false, scheme: nil, ip_address: false, punycode: false, error: error)
  end

  def ip_address?(host)
    IPAddr.new(host)
    true
  rescue IPAddr::InvalidAddressError
    false
  end
end
