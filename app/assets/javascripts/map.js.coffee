window.Map = class Map
  constructor: (@myOptions) ->
    new google.maps.Map(document.getElementById("map"), @myOptions)

$ ->
  map = new Map
    center: new google.maps.LatLng(-34.397, 150.644)
    zoom: 8
    mapTypeId: google.maps.MapTypeId.ROADMAP
