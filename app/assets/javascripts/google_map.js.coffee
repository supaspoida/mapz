#= require 'vendor/markerclusterer'

$ ->
  map = new google.maps.Map document.getElementById("map"),
    center: new google.maps.LatLng(-34.397, 150.644)
    zoom: 8
    mapTypeId: google.maps.MapTypeId.ROADMAP

  bounds = new google.maps.LatLngBounds

  markers = $.map Shows, (show) ->
    position = new google.maps.LatLng(show.lat, show.lng)
    new google.maps.Marker
      position: position
      title: 'show'

  $.each markers, (i, marker) ->
    bounds.extend marker.position

  map.fitBounds bounds

  new MarkerClusterer map, markers
