#= require 'vendor/d3.v2.min'
#= require 'timeline'

$ ->
  timeline = new Timeline
  timeline.render
    width: $(document).width()
    height: $(document).height()
    selector: '#nav'

  map = new Map

window.Map = class Map
  constructor: ->
    width = $('#map').width()
    height = $('#map').height()
    centered = undefined

    projection = d3.geo.albersUsa().scale(width).translate([ 0, 0 ])
    path = d3.geo.path().projection projection
    svg = d3.select('#map').append('svg').attr('width', width).attr 'height', height

    svg.append("rect")
       .attr("class", "background")
       .attr("width", width)
       .attr("height", height)
       .on "click", click

    g = svg.append("g")
           .attr("transform", "translate(" + width / 2 + "," + height / 2 + ")")
           .append("g").attr("id", "states")

    d3.json "/states.json", (json) ->
      g.selectAll("path")
       .data(json.features)
       .enter()
       .append("path")
       .attr("d", path)
       .attr('id', (state) -> state.properties.name)
       .on("click", click)

    click = (d) ->
      $('.callout').fadeOut()
      x = 0
      y = 0
      k = 1
      if d and centered isnt d
        centroid = path.centroid(d)
        x = -centroid[0]
        y = -centroid[1]
        k = 4
        centered = d
        $("##{d.properties.name}.callout").fadeIn()
      else
        centered = null
      g.selectAll("path").classed "active", centered and (d) ->
        d is centered

      g.transition()
       .duration(1000)
       .attr("transform", "scale(" + k + ")translate(" + x + "," + y + ")")
       .style "stroke-width", 1.5 / k + "px"
