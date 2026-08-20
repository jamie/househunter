require "test_helper"

class SearchAreaTest < ActiveSupport::TestCase
  test "center and span are derived from the bounds" do
    area = search_areas(:one)

    assert_in_delta (area.lat_min + area.lat_max) / 2, area.center_lat, 0.0001
    assert_in_delta (area.lng_min + area.lng_max) / 2, area.center_lng, 0.0001
    assert_in_delta area.lat_max - area.lat_min, area.height, 0.0001
    assert_in_delta area.lng_max - area.lng_min, area.width, 0.0001
  end

  test "invalid when max is not greater than min" do
    area = SearchArea.new(name: "Bad", lat_min: 49.1, lat_max: 49.1, lng_min: -123.9, lng_max: -123.8)

    assert_not area.valid?
    assert_includes area.errors[:lat_max], "must be greater than lat_min"
  end

  test "invalid when a span exceeds MAX_SPAN" do
    area = SearchArea.new(name: "Huge", lat_min: 49.0, lat_max: 49.0 + SearchArea::MAX_SPAN + 0.01, lng_min: -124.0, lng_max: -123.9)

    assert_not area.valid?
    assert_includes area.errors[:lat_max], "span can't exceed #{SearchArea::MAX_SPAN} degrees"
  end

  test "recenter recomputes bounds around a new center, keeping the span" do
    area = search_areas(:one)
    width = area.width
    height = area.height

    area.recenter(center_lat: 50.0, center_lng: -125.0)

    assert_in_delta 50.0, area.center_lat, 0.0001
    assert_in_delta(-125.0, area.center_lng, 0.0001)
    assert_in_delta width, area.width, 0.0001
    assert_in_delta height, area.height, 0.0001
  end
end
