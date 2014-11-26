$( document ).ready(function() {

  //API key   
  L.mapbox.accessToken = 'pk.eyJ1Ijoiam1hYzg0MjQiLCJhIjoiczNhRG5wNCJ9.9Th4UpP0dmkcTH_c9bV2tA';

  //Initialize map with base tileLayer (no data)
  var map = L.mapbox.map('map')
    .setView([34.1014861,-118.4571974], 8)
    .addLayer(L.mapbox.tileLayer('https://api.tiles.mapbox.com/v3/jmac8424.k6lb8hf1.json'));

  var geoJsonFeatures = [];
  var zipcode = document.getElementById('filter-zipcode'),
    all = document.getElementById('filter-all'),
    active = document.getElementById('filter-active'),
    business = document.getElementById('filter-business');

  // Add custom popup html to each marker.
  var clusterGroup = L.markerClusterGroup();
  map.addLayer(clusterGroup);
  $.get('/businesses/get_markers.json', function(response) {
    geoJsonFeatures = response.features;
    addToMap(geoJsonFeatures);
  });

  // Marker Clusters:
  function addToMap(geoJsonFeatures) {
    clusterGroup.clearLayers();
    for( var idx in geoJsonFeatures ) {
      var feature = geoJsonFeatures[idx];
      var display_name = lazy_list[feature.properties.category]; 
      var marker = new L.marker(new L.LatLng(feature.geometry.coordinates[1],feature.geometry.coordinates[0]), {
            'icon': L.mapbox.marker.icon({'marker-size': feature.properties['marker-size'], 'marker-color': feature.properties['marker-color']})
          });
      var popupContent =  '<div id="' + feature.properties.id + '" class="popup">' +
                          '<h2>' + feature.properties.title + '</h2>' +
                          '<h5>' + display_name + '</h5>' +
                          '<div class="details">' +
                          '<img src="' + feature.properties.image + '">' +
                          '<address>' + feature.properties.address + '</address>' + 
                          '<zipcode>' + feature.properties.zipcode + '</zipcode>'
                              '</div>' +
                          '</div>';
      marker.bindPopup(popupContent, { closeButton: false, minWidth: 320 });
      clusterGroup.addLayer(marker);
    };
    map.addLayer(clusterGroup);
  }

  // Show all markers
  document.getElementById('filter-all').onclick = function(e) {
    zipcode.className = '';
    business.className = '';
    this.className = 'business';
    matches = [];
    for(var idx in geoJsonFeatures) {
      {
        matches.push(geoJsonFeatures[idx]);
      }
    }
    addToMap(matches);
    return false;
  };

  // Filter markers by zipcode
  document.getElementById('filter-zipcode').onclick = function(e) {
    all.className = '';
    business.className = '';
    this.className = 'business';
    matches = [];
    for(var idx in geoJsonFeatures) {
      var feature = geoJsonFeatures[idx];
      if (feature.properties.zipcode === 90064) {
        matches.push(feature);
      }
    }
    addToMap(matches);
    return false;
  };

  //Filter markers by Active Life category

  document.getElementById('filter-business').onclick = function(e) {
    all.className = '';
    business.className = '';
    this.className = 'business';
    matches = [];
    for(var idx in geoJsonFeatures) {
      var feature = geoJsonFeatures[idx];
      if (feature.properties.category === 'active') {
        matches.push(feature);
      }
    }
    addToMap(matches);
    return false;
  };

  // Quick/ugly fix for display_name on pop up windows
  var lazy_list = {
    'active': 'Active Life',
    'arts': 'Arts',
    'auto': 'Auto',
    'beautysvc': 'Beauty Services',
    'education': 'Education',
    'eventservices': 'Event Services',
    'financialservices': 'Financial Services',
    'food': 'Food',
    'health': 'Health',
    'homeservices': 'Home Services',
    'nightlife': 'Nightlife',
    'pets': 'Pets',
    'hotelstravel': 'Hotels Travel',
    'localflavor': 'Local Flavor',
    'localservices': 'Local Services',
    'massmedia': 'Mass Media',
    'professional': 'Professional',
    'publicservicesgovt': 'Public Services/Govt',
    'realestate': 'Real Estate',
    'religiousorgs': 'Religious Orgs.',
    'restaurants':  'Restaurants',
    'shopping': 'Shopping'
  };
});