require "digest"
require "base64"
require "json"
require "net/http"
require "uri"

class ThreatIntelligenceChecker
  Result = Struct.new(:checked?, :malicious?, :suspicious?, :provider, :reason, keyword_init: true)

  GOOGLE_SAFE_BROWSING_ENDPOINT = "https://safebrowsing.googleapis.com/v4/threatMatches:find"
  VIRUSTOTAL_ENDPOINT = "https://www.virustotal.com/api/v3/urls"

  def self.call(url)
    new(url).call
  end

  def initialize(url)
    @url = url
  end

  def call
    google_result = check_google_safe_browsing
    return google_result if google_result&.checked? && google_result.malicious?

    virus_total_result = check_virustotal
    return virus_total_result if virus_total_result&.checked?

    google_result || Result.new(checked?: false, malicious?: false, suspicious?: false)
  end

  private

  def check_google_safe_browsing
    api_key = ENV["GOOGLE_SAFE_BROWSING_API_KEY"].presence || SecuritySetting.fetch_value("google_safe_browsing_api_key").presence
    return nil if api_key.blank?

    uri = URI("#{GOOGLE_SAFE_BROWSING_ENDPOINT}?key=#{api_key}")
    response = post_json(uri, google_safe_browsing_payload)
    body = JSON.parse(response.body.presence || "{}")
    matches = body["matches"].to_a

    Result.new(
      checked?: true,
      malicious?: matches.any?,
      suspicious?: false,
      provider: "Google Safe Browsing",
      reason: matches.any? ? "Google Safe Browsing matched this URL as unsafe" : "Google Safe Browsing did not match this URL"
    )
  rescue StandardError => e
    Result.new(checked?: false, malicious?: false, suspicious?: false, provider: "Google Safe Browsing", reason: "Google Safe Browsing check failed: #{e.message}")
  end

  def check_virustotal
    api_key = ENV["VIRUSTOTAL_API_KEY"].presence || SecuritySetting.fetch_value("virustotal_api_key").presence
    return nil if api_key.blank?

    url_id = Base64.urlsafe_encode64(@url).delete("=")
    uri = URI("#{VIRUSTOTAL_ENDPOINT}/#{url_id}")
    request = Net::HTTP::Get.new(uri)
    request["x-apikey"] = api_key
    response = Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 1.5, read_timeout: 1.5) { |http| http.request(request) }
    body = JSON.parse(response.body.presence || "{}")
    stats = body.dig("data", "attributes", "last_analysis_stats") || {}
    malicious = stats["malicious"].to_i
    suspicious = stats["suspicious"].to_i

    Result.new(
      checked?: response.code.to_i.between?(200, 299),
      malicious?: malicious.positive?,
      suspicious?: suspicious.positive?,
      provider: "VirusTotal",
      reason: "VirusTotal reports #{malicious} malicious and #{suspicious} suspicious engines"
    )
  rescue StandardError => e
    Result.new(checked?: false, malicious?: false, suspicious?: false, provider: "VirusTotal", reason: "VirusTotal check failed: #{e.message}")
  end

  def google_safe_browsing_payload
    {
      client: {
        clientId: "crown-link-guard",
        clientVersion: "1.0.0"
      },
      threatInfo: {
        threatTypes: %w[MALWARE SOCIAL_ENGINEERING UNWANTED_SOFTWARE POTENTIALLY_HARMFUL_APPLICATION],
        platformTypes: %w[ANY_PLATFORM],
        threatEntryTypes: %w[URL],
        threatEntries: [{ url: @url }]
      }
    }
  end

  def post_json(uri, payload)
    request = Net::HTTP::Post.new(uri)
    request["Content-Type"] = "application/json"
    request.body = payload.to_json
    Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 1.5, read_timeout: 1.5) { |http| http.request(request) }
  end
end
