class BrandImpersonationDetector
  Brand = Struct.new(:name, :domains, keyword_init: true)

  BRANDS = [
    Brand.new(name: "Booking.com", domains: %w[booking.com]),
    Brand.new(name: "Expedia", domains: %w[expedia.com expediapartnercentral.com hotels.com]),
    Brand.new(name: "Eviivo", domains: %w[eviivo.com]),
    Brand.new(name: "Zoho", domains: %w[zoho.com zohodesk.com]),
    Brand.new(name: "Crown Business Solutions", domains: %w[crownbs.com]),
    Brand.new(name: "Microsoft", domains: %w[microsoft.com live.com office.com office365.com outlook.com]),
    Brand.new(name: "Google", domains: %w[google.com gmail.com]),
    Brand.new(name: "PayPal", domains: %w[paypal.com]),
    Brand.new(name: "DocuSign", domains: %w[docusign.com]),
    Brand.new(name: "Dropbox", domains: %w[dropbox.com]),
    Brand.new(name: "Adobe", domains: %w[adobe.com])
  ].freeze

  HOMOGLYPHS = {
    "0" => "o",
    "1" => "l",
    "3" => "e",
    "4" => "a",
    "5" => "s",
    "7" => "t",
    "@" => "a",
    "$" => "s"
  }.freeze

  Result = Struct.new(:matched?, :brand, :reason, :score, keyword_init: true)

  def self.call(domain)
    new(domain).call
  end

  def initialize(domain)
    @domain = domain.to_s.downcase.sub(/\Awww\./, "")
    @root_domain = UrlNormalizer.root_domain_for(@domain)
    @root_label = @root_domain.split(".").first.to_s
    @normalized_label = normalize_label(@root_label)
  end

  def call
    BRANDS.each do |brand|
      return safe_brand_result if official_brand_domain?(brand)

      result = detect_brand(brand)
      return result if result&.matched?
    end

    Result.new(matched?: false, score: 0)
  end

  private

  def safe_brand_result
    Result.new(matched?: false, score: 0)
  end

  def official_brand_domain?(brand)
    brand.domains.any? { |domain| @domain == domain || @domain.end_with?(".#{domain}") }
  end

  def detect_brand(brand)
    brand.domains.each do |official_domain|
      official_label = official_domain.split(".").first
      normalized_official = normalize_label(official_label)

      if @domain.include?("#{official_domain}.")
        return Result.new(matched?: true, brand: brand.name, score: 60, reason: "#{brand.name} domain appears inside a different real domain")
      end

      if @normalized_label.include?(normalized_official) && @root_domain != official_domain
        return Result.new(matched?: true, brand: brand.name, score: 35, reason: "Domain name includes #{brand.name} branding but is not an official #{brand.name} domain")
      end

      distance = levenshtein(@normalized_label, normalized_official)
      if normalized_official.length >= 5 && distance.between?(1, 2)
        return Result.new(matched?: true, brand: brand.name, score: 45, reason: "Domain looks like a typo or lookalike of #{brand.name}")
      end
    end

    nil
  end

  def normalize_label(label)
    label.to_s.downcase.each_char.map { |char| HOMOGLYPHS.fetch(char, char) }.join.gsub(/[^a-z0-9]/, "")
  end

  def levenshtein(left, right)
    return right.length if left.empty?
    return left.length if right.empty?

    costs = (0..right.length).to_a
    left.chars.each_with_index do |left_char, i|
      previous = i
      costs[0] = i + 1

      right.chars.each_with_index do |right_char, j|
        current = costs[j + 1]
        costs[j + 1] = if left_char == right_char
                         previous
                       else
                         [current, previous, costs[j]].min + 1
                       end
        previous = current
      end
    end

    costs[right.length]
  end
end
