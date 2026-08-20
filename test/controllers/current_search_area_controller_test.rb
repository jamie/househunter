require "test_helper"

class CurrentSearchAreaControllerTest < ActionDispatch::IntegrationTest
  setup do
    @first, @second = SearchArea.order(:id).to_a
  end

  test "renders the panel for a turbo frame request" do
    get current_search_area_url, headers: {"Turbo-Frame" => "current_search_area_frame"}

    assert_response :success
    assert_select "#search_area_name", text: @first.name
  end

  test "redirects when not requested as a turbo frame" do
    get current_search_area_url

    assert_redirected_to root_url
  end

  test "cycling next/prev moves through search areas and wraps around" do
    get current_search_area_url, params: {direction: "next"}, headers: {"Turbo-Frame" => "current_search_area_frame"}
    assert_select "#search_area_name", text: @second.name

    get current_search_area_url, params: {direction: "next"}, headers: {"Turbo-Frame" => "current_search_area_frame"}
    assert_select "#search_area_name", text: @first.name

    get current_search_area_url, params: {direction: "prev"}, headers: {"Turbo-Frame" => "current_search_area_frame"}
    assert_select "#search_area_name", text: @second.name
  end
end
