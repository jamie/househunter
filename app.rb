require './setup'

require 'sinatra'

get '/' do
  @listings = Listing.where("last_import > ?", 5.days.ago).order(:last_import).all.reverse
  erb :index
end

__END__

@@ index

<!DOCTYPE html>
<html>
<head>
  <title>Househunter</title>
  <style type="text/css">
    #map_canvas { width: 100%; height: 700px; }
    #map_legend { position: absolute; bottom: 10px; left: 10px; background: white; }
  </style>

  <script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.6.4/jquery.min.js"></script>
  <script type="text/javascript" src="http://maps.googleapis.com/maps/api/js?sensor=true"></script>
  <script type="text/javascript">
    function initialize() {
      var latlng = new google.maps.LatLng(49.176766,-123.969383);
      var myOptions = {
        zoom: 12,
        center: latlng,
        mapTypeId: google.maps.MapTypeId.ROADMAP
      };
      var map = new google.maps.Map(document.getElementById("map_canvas"), myOptions);

      var infoContents = [];
      var infoWindows = [];
      var markers = [];
      <% @listings.each do |listing| %>
        <% next if listing.last_import < 5.days.ago %>

        markers[<%= listing.id %>] = new google.maps.Marker({
          position: new google.maps.LatLng(<%= listing.lat %>,<%= listing.lng %>),
          map: map, 
          icon: '<%= listing.map_icon_uri %>',
          title: "<%= listing.address %>"
        });
        
        var infoWindow = new google.maps.InfoWindow({content: ""});

        google.maps.event.addListener(markers[<%= listing.id %>], 'click', function() {
          infoWindow.content = $('#listing_<%= listing.id %>').html();

          infoWindow.open(map,markers[<%= listing.id %>]);
        });
      <% end %>
    }
  </script>
</head>

<body onload="initialize();">
  <div id="map_canvas"></div>
  <div id="map_legend">
    <table>
      <tr><td>     </td><td><img src="http://maps.google.com/mapfiles/ms/icons/pink.png"></td>  <td>$180k</td></tr>
      <tr><td>$180k</td><td><img src="http://maps.google.com/mapfiles/ms/icons/purple.png"></td><td>$210k</td></tr>
      <tr><td>$210k</td><td><img src="http://maps.google.com/mapfiles/ms/icons/blue.png"></td>  <td>$240k</td></tr>
      <tr><td>$240k</td><td><img src="http://maps.google.com/mapfiles/ms/icons/green.png"></td> <td>$270k</td></tr>
      <tr><td>$270k</td><td><img src="http://maps.google.com/mapfiles/ms/icons/yellow.png"></td><td>$300k</td></tr>
      <tr><td>$300k</td><td><img src="http://maps.google.com/mapfiles/ms/icons/orange.png"></td><td>$330k</td></tr>
      <tr><td>$330k</td><td><img src="http://maps.google.com/mapfiles/ms/icons/red.png"></td>   <td>     </td></tr>
    </table>
  </div>

  <% @listings.each do |listing| %>
    <div style="float: left; width: 240px; height: 220px;">
      <div id="listing_<%= listing.id %>">
        <a href="<%= listing.url %>"><%= listing.address %></a><br>
        <%= listing.last_imported["OrganizationName"].join(',<br> ') %><br>
        <img src="<%= listing.last_imported['PropertyLowResImagePath'] + listing.last_imported['PropertyLowResPhotos'].first.to_s %>"/><br>
        <%= listing.price %> on <%= listing.last_import.strftime('%d %b') %>
        <% if listing.last_import - listing.created_at > 10 %> (since <%= listing.created_at.strftime('%d %b') %>)<% end %>
        <br>
        <%= listing.last_imported["Bedrooms"] %> bed, <%= listing.last_imported["Bathrooms"] %> bath<br>
      </div>
      <% "<p>#{listing.last_imported}</p>" %>
    </div>
  <% end %>
</body>
</html>

