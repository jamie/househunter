class Listing < ActiveRecord::Base
  UNIMPORTANT_ATTRS = %w(PropertyImagePath PropertyLowResImagePath PropertyLowResPhotos Latitude Longitude OrganizationName)
  
  def self.import(attrs)
    listing = where(:mls => attrs['MLS']).first
    listing ||= create(:mls => attrs['MLS'])
    listing.record(attrs)
    listing.import!
  end

  def record(attrs)
    return if last_imported == attrs
    print '.'
    if json.blank?
      self.json = attrs.to_json
    else
      self.json = self.json + "\n" + attrs.to_json
    end
    if !((last_imported.diff attrs).keys - UNIMPORTANT_ATTRS).empty?
      p ((last_imported.diff attrs).keys - UNIMPORTANT_ATTRS) unless last_imported.empty?
      self.last_import = Time.now
    end
    save
  end

  def last_imported
    JSON.parse((json||"").split("\n").last || "{}")
  end

  def import!
    a = last_imported
    self.lat =     a['Latitude']
    self.lng =     a['Longitude']
    self.address = a['Address'].blank? ? 'Unknown' : a['Address']
    self.price =   a['Price']
    save
  end
  
  def map_icon_uri
    dot = (last_import > 2.hours.ago ? '-dot' : '')
    color = case
    when price_int < 180_000; 'pink'
    when price_int < 210_000; 'purple'
    when price_int < 240_000; 'blue'
    when price_int < 270_000; 'green'
    when price_int < 300_000; 'yellow'
    when price_int < 330_000; 'orange'
    else                    ; 'red'
    end
    "http://maps.google.com/mapfiles/ms/icons/#{color}#{dot}.png"
  end
  
  def price_int
    price.gsub(/[^0-9]/, '').to_i
  end

  def url
    id = last_imported['PropertyID']
    key = last_imported['PidKey']
    "http://www.realtor.ca/propertyDetails.aspx?propertyId=#{id}&PidKey=#{key}"
  end
end
