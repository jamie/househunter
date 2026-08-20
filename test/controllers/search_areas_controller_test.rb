require "test_helper"

class SearchAreasControllerTest < ActionDispatch::IntegrationTest
  test "index lists all search areas" do
    get search_areas_url

    assert_response :success
    assert_select "input.search_area_name_input[value=?]", search_areas(:one).name
    assert_select "input.search_area_name_input[value=?]", search_areas(:two).name
  end

  test "update saves new bounds" do
    area = search_areas(:one)

    patch search_area_url(area), params: {search_area: {name: "Renamed", lat_min: 49.0, lat_max: 49.2, lng_min: -124.0, lng_max: -123.9}}, as: :json

    assert_response :success
    area.reload
    assert_equal "Renamed", area.name
    assert_in_delta 49.0, area.lat_min.to_f, 0.0001
  end

  test "update rejects invalid bounds" do
    area = search_areas(:one)

    patch search_area_url(area), params: {search_area: {lat_min: 49.0, lat_max: 49.0}}, as: :json

    assert_response :unprocessable_entity
  end

  test "clone duplicates a search area" do
    area = search_areas(:one)

    assert_difference "SearchArea.count", 1 do
      post clone_search_area_url(area)
    end

    clone = SearchArea.order(:id).last
    assert_equal "#{area.name} copy", clone.name
    assert_equal area.lat_min, clone.lat_min

    assert_redirected_to search_areas_url
  end

  test "destroy removes a search area" do
    assert_difference "SearchArea.count", -1 do
      delete search_area_url(search_areas(:two))
    end

    assert_redirected_to search_areas_url
  end

  test "destroy refuses to remove the last search area" do
    SearchArea.where.not(id: search_areas(:one).id).destroy_all

    assert_no_difference "SearchArea.count" do
      delete search_area_url(search_areas(:one))
    end

    assert_redirected_to search_areas_url
  end
end
