class Listing < ActiveRecord::Base
  UNLIMITED_AGE = 28

  has_many :imports, dependent: :destroy

  def self.filtered = where.not(status: "ignore")

  def self.starred = where(starred: true)

  def self.fresh = where(updated_at: 3.days.ago..)

  def self.recent(n = 5)
    if n.to_i == UNLIMITED_AGE
      all
    else
      where(created_at: (n.to_i + 1).days.ago..)
    end
  end

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

  def last_imported = imports.last&.json || {}

  def marker_icon(price_spread, last_import)
    index = price_spread.index { |spread| price < spread }
    if starred?
      "star#{index}"
    elsif created_at > 8.hours.ago
      "house#{index}new"
    elsif imported_at > 1.days.ago
      "house#{index}recent"
    else
      "house#{index}"
    end
  end
end
