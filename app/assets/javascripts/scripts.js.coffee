# TO DO:
# 1. add markers
# 2. add option to toggle based on category, state, zipcode
# 3. add function that dynamically sets origin?

# $(document).ready ->

#   map = L.mapbox.map('map', 'jmac8424.k6lb8hf1', scrollWheelZoom: false).setView([34.0500, -118.2500], 14)

#   # get JSON object
#   # on success, parse it and
#   # hand it over to MapBox for mapping
#   $.ajax
#     url: '/businesses/get_markers' 
#     type: 'GET'
#     dataType: 'json'
#     success: (data)->
#       geojson = $.parseJSON(data)
#       map.featureLayer.setGeoJSON(geojson)

  # var layer = L.mapbox.tileLayer('jmac8424.k6lb8hf1');
  # layer.on('ready', function() {
  #   // the layer has been fully loaded now, and you can
  #   // call .getTileJSON and investigate its properties
  # });

# test marker point:
  # L.mapbox.featureLayer(
  #   type: "Feature",
  #   geometry:
  #     type: "Point",
  #     coordinates: [
  #       34.0771354,
  #       -118.2634681
  #     ],
  #   properties:
  #     title: "CrossFit Sunset",
  #     description: "1030 N Alvarado St, Los Angeles, CA",
  #     "marker-size": "large",
  #     "marker-color": "#fff"
  #   ).addTo(map)




  # *************** TO DO ******
  # create custom popup

  # add custom popups to each marker
  # map.featureLayer.on 'layeradd', (e) ->
  # marker = e.layer
  # properties = marker.feature.properties
  
  # popupContent =  '<div class="popup">' +
  #                   '<h3>' + properties.name + '</h3>' +
  #                   '<p>' + properties.address + '</p>' +
  #                 '</div>'

  # # http://leafletjs.com/reference.html#popup
  # marker.bindPopup popupContent,
  #   closeButton: false
  #   minWidth: 320