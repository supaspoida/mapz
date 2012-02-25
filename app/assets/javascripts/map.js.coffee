$ ->
  map = new google.maps.Map document.getElementById("map"),
    center: new google.maps.LatLng(-34.397, 150.644)
    zoom: 8
    mapTypeId: google.maps.MapTypeId.ROADMAP

  bounds = new google.maps.LatLngBounds

  markers = $.map Shows, (show) ->
    new google.maps.LatLng(show.lat, show.lng)

  $.each markers, (i, marker) ->
    bounds.extend marker
    new google.maps.Marker
      position: marker
      map: map
      title: 'show'

  map.fitBounds bounds
