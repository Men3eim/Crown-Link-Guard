require "net/http"
require "uri"

class RedirectChainScanner
  Result = Struct.new(:checked?, :chain, :final_url, :final_domain, :changed_domain?, :error, keyword_init: true)

  MAX_REDIRECTS = 4
  TIMEOUT_SECONDS = 1.5

  def self.call(url)
    new(url).call
  end

  def initialize(url)
    @url = url
  end

  def call
    uri = URI.parse(@url)
    chain = [uri.to_s]
    original_domain = normalized_domain(uri.host)

    MAX_REDIRECTS.times do
      response = request(uri)
      location = response["location"] if response.is_a?(Net::HTTPRedirection)
      break if location.blank?

      uri = URI.join(uri, location)
      chain << uri.to_s
    end

    final_domain = normalized_domain(uri.host)
    Result.new(
      checked?: true,
      chain: chain,
      final_url: uri.to_s,
      final_domain: final_domain,
      changed_domain?: original_domain.present? && final_domain.present? && original_domain != final_domain,
      error: nil
    )
  rescue StandardError => e
    Result.new(checked?: false, chain: [], final_url: nil, final_domain: nil, changed_domain?: false, error: e.message)
  end

  private

  def request(uri)
    Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https", open_timeout: TIMEOUT_SECONDS, read_timeout: TIMEOUT_SECONDS) do |http|
      request = Net::HTTP::Head.new(uri)
      request["User-Agent"] = "Crown Link Guard/1.0"
      response = http.request(request)

      if response.is_a?(Net::HTTPMethodNotAllowed) || response.is_a?(Net::HTTPForbidden)
        get_request = Net::HTTP::Get.new(uri)
        get_request["User-Agent"] = "Crown Link Guard/1.0"
        return http.request(get_request)
      end

      response
    end
  end

  def normalized_domain(host)
    host.to_s.downcase.sub(/\Awww\./, "")
  end
end
