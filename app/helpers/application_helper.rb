module ApplicationHelper
  def leaflet_icon_definition(icon_url)
    <<~JS.html_safe
      #{icon_url}: L.icon({
        iconUrl: '#{image_path(icon_url)}',
        iconSize: [20,20],
        iconAnchor: [10,10]
      })
    JS
  end
end
