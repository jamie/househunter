class Hash
  def diff(h2)
    dup.delete_if { |k, v| h2[k] == v }.merge(h2.dup.delete_if { |k, v| has_key?(k) })
  end
end

class Listing < ActiveRecord::Base
  def self.filtered
    where("status != ?", "ignore")
  end

  def self.recent
    where("updated_at > ?", 5.days.ago)
  end

  def last_imported
    JSON.parse((json || "").split("\n").last || "{}")
  end

  def bedrooms = last_imported.dig("Building", "Bedrooms")

  def bathrooms = last_imported.dig("Building", "BathroomTotal")

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
