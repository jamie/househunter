class Listing < ActiveRecord::Base
  def self.filtered = where("status != ?", "ignore")

  def self.recent(n = 5) = where("created_at > ?", n.days.ago)

  def self.min_price(price) = price.presence ? where("price > ?", price) : all

  def self.max_price(price) = price.presence ? where("price < ?", price) : all

  def self.price_range(min_price, max_price) = min_price(min_price).max_price(max_price)

  def self.price_spread
    prices = all.pluck(:price)
    sum = prices.sum(0.0)
    size = prices.size
    mean = sum / size
    stddev = Math.sqrt(prices.map { |price| (price - mean)**2 }.sum / size)
    [
      0,
      mean - 1 * stddev,
      mean - 0.5 * stddev,
      mean,
      mean + 0.5 * stddev,
      mean + 1 * stddev,
      mean + 1.5 * stddev
    ].map { |price| price.round(-4) } + [Float::INFINITY]
  end

  def last_imported
    JSON.parse((json || "").split("\n").last || "{}")
  end

  def bedrooms = last_imported.dig("Building", "Bedrooms")

  def bathrooms = last_imported.dig("Building", "BathroomTotal")

  def external_url = "https://www.realtor.ca#{last_imported.dig("RelativeURLEn")}"

  def marker_icon(price_spread)
    index = price_spread.index { |spread| price < spread }
    if starred?
      "star#{index}"
    elsif created_at > 12.hours.ago # TODO: Most recent import
      "house#{index}gs"
    elsif created_at > 3.days.ago
      "house#{index}ss"
    else
      "house#{index}"
    end
  end

  def last_update
    date = begin
      DateTime.parse(last_imported.dig("PriceChangeDateUTC"))
    rescue
      nil
    end
    date ||= created_at
    date.strftime("%b %d")
  end

  def map_icon_uri
    return "/starpin.png" if status == "remember"

    color = if price < 180_000 then "pink"
    elsif price < 210_000 then "purple"
    elsif price < 240_000 then "blue"
    elsif price < 270_000 then "green"
    elsif price < 300_000 then "yellow"
    elsif price < 330_000 then "orange"
    else
      "red"
    end
    style = ((imported_at > 20.hours.ago) ? "-dot" : "")
    "http://maps.google.com/mapfiles/ms/icons/#{color}#{style}.png"
  end

  def url
    id = last_imported["PropertyID"]
    key = last_imported["PidKey"]
    "http://www.realtor.ca/propertyDetails.aspx?propertyId=#{id}&PidKey=#{key}"
  end

  def tooltip_photo
    last_imported.dig("Property", "Photo", 0, "MedResPath")
  end
end
