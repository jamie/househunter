require './setup'

require 'sinatra'
require 'cgi'
require 'open-uri'

get '/' do
  @listings = Listing.recent.filtered.all
  erb :index
end

get '/listing/:id/mls' do
  listing = Listing.find(params[:id])
  out = open(listing.url).read
  out.sub!("<SCRIPT LANGUAGE='Javascript'>if (window != top) top.location.href = location.href;</SCRIPT>", "")
  out.sub!('"REALTOR">', '"REALTOR"><base href="http://www.realtor.ca/">')
  out
end

post '/listing/:id/:status' do
  pass unless %w(new ignore remember).include? params[:status]
  listing = Listing.find(params[:id])
  listing.status = params[:status]
  listing.save
end

__END__

@@ index

<!DOCTYPE html>
<html>
<head>
  <title>Househunter</title>
  <link rel="stylesheet" href="http://twitter.github.com/bootstrap/1.3.0/bootstrap.min.css">
  <style type="text/css">
    #mls_frame { position: absolute; top: 0; right: 0; }
    #map_canvas { width: 200px; height: 200px; overflow: hidden; }
    #map_legend { position: absolute; bottom: 10px; left: 10px; background: white; }
    #map_legend table { margin: 0; }
    #map_legend th, #map_legend td { padding: 0; margin: 0; }
    .listing_info { width: 250px; }
    .photo { float: left; }
  </style>

  <script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.6.4/jquery.min.js"></script>
  <script type="text/javascript" src="http://maps.googleapis.com/maps/api/js?sensor=true"></script>
  <script type="text/javascript">
    var markers = [];
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
      <% @listings.each do |listing| %>
        markers[<%= listing.id %>] = new google.maps.Marker({
          position: new google.maps.LatLng(<%= listing.lat %>,<%= listing.lng %>),
          map: map,
          <% if listing.map_icon_uri =~ /star/ %>zIndex: 999,<% end %>
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
    function resize() {
      $('#mls_frame').css('height', document.height-4);
      $('#mls_frame').css('width', 605);
      $('#map_canvas').css('height', document.height);
      $('#map_canvas').css('width', document.width - $('#mls_frame').width());
    }
    function wrap_links() {
      $('.listing_info .status').live('click', function() {
        $.ajax(this.href, {type: 'POST'});
        m = this.href.match('listing/([0-9]+)/(.*)');
        if (m) {
          if (m[2] == 'ignore') { markers[m[1]].setMap(null); }
          if (m[2] == 'remember') { markers[m[1]].setIcon('/starpin.png'); }
        }
        return false;
      });
    }
  </script>
</head>

<body onload="initialize(); resize(); wrap_links();">
  <div id="map_canvas">
  </div>
  <div id="map_legend">
    <table>
      <tr><td>     </td><td><img src="http://maps.google.com/mapfiles/ms/icons/pink.png">  </td><td>$180k</td></tr>
      <tr><td>$180k</td><td><img src="http://maps.google.com/mapfiles/ms/icons/purple.png"></td><td>$210k</td></tr>
      <tr><td>$210k</td><td><img src="http://maps.google.com/mapfiles/ms/icons/blue.png">  </td><td>$240k</td></tr>
      <tr><td>$240k</td><td><img src="http://maps.google.com/mapfiles/ms/icons/green.png"> </td><td>$270k</td></tr>
      <tr><td>$270k</td><td><img src="http://maps.google.com/mapfiles/ms/icons/yellow.png"></td><td>$300k</td></tr>
      <tr><td>$300k</td><td><img src="http://maps.google.com/mapfiles/ms/icons/orange.png"></td><td>$330k</td></tr>
      <tr><td>$330k</td><td><img src="http://maps.google.com/mapfiles/ms/icons/red.png">   </td><td>     </td></tr>
    </table>
  </div>
  <iframe id="mls_frame" name="mls_frame">You need a newer browser.</iframe>

  <% @listings.each do |listing| %>
    <div style="float: left; height: 200px; display: none;" id="listing_<%= listing.id %>" >
      <div class="listing_info">
        <%= listing.mls %>, <a href="listing/<%= listing.id %>/mls" target="mls_frame"><%= listing.address %></a><br>
        <%= listing.last_imported["OrganizationName"].join(',<br> ') %><br>
        <img class="photo" src="<%= listing.last_imported['PropertyLowResImagePath'] + listing.last_imported['PropertyLowResPhotos'].first.to_s %>"/>
        <strong>&nbsp; &nbsp; <%= listing.price %></strong><br>
        Added <%= listing.created_at.strftime('%d %b') %><br>
        <% if listing.imported_at - listing.created_at > 10 %> Updated <%= listing.created_at.strftime('%d %b') %><br><% end %>
        <br>
        <%= listing.last_imported["Bedrooms"] %> bed, <%= listing.last_imported["Bathrooms"] %> bath<br>
        <% if listing.status != 'ignore' %>
          <a class="status" href="/listing/<%= listing.id %>/ignore">ignore</a>
        <% end %>
        <% if listing.status == 'remember' %>
          <a class="status" href="/listing/<%= listing.id %>/new">unremember</a><br/>
        <% else %>
          <a class="status" href="/listing/<%= listing.id %>/remember">remember</a><br/>
        <% end %>
      </div>
      <% "<p>#{listing.last_imported}</p>" %>
    </div>
  <% end %>
</body>
</html>

