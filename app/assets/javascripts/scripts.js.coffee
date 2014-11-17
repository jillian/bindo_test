$(document).ready ->

  map = L.mapbox.map('map', 'jmac8424.k6lb8hf1', scrollWheelZoom: false).setView([34.0500, -118.2500], 14)

  118.2500
  # get JSON object
  # on success, parse it and
  # hand it over to MapBox for mapping
  $.ajax
  dataType: 'text'
  url: '.json'
  success: (data) ->
    geojson = $.parseJSON(data)
    map.featureLayer.setGeoJSON(geojson)

  # add custom popups to each marker
  map.featureLayer.on 'layeradd', (e) ->
  marker = e.layer
  properties = marker.feature.properties

  # *************** TO DO ******
  # create custom popup
  popupContent =  '<div class="popup">' +
                    '<h3>' + properties.name + '</h3>' +
                    '<p>' + properties.address + '</p>' +
                  '</div>'

  # http://leafletjs.com/reference.html#popup
  marker.bindPopup popupContent,
    closeButton: false
    minWidth: 320