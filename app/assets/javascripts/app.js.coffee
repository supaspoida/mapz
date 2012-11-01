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
    padding = 20
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

    d3.json '/shows.json', (json) ->
      data = d3.nest()
        .key((d) -> d.year)
        .key((d) -> d.state)
        .rollup((d) -> d.length)
        .map(json)

      colors = new Map.Colors
      lightest = colors.lightest()

      years = d3.keys data
      [firstYear, lastYear] = [d3.first(years), d3.last(years)]

      yScale = d3.scale.linear()
        .domain([firstYear, lastYear])
        .range([padding, height - padding * 2])

      yearAxis = d3.svg.axis()
        .scale(yScale)
        .orient("left")
        .ticks(years.length)
        .tickFormat (d) -> d

      axis = svg.append("g")
        .attr('fill', -> lightest)
        .attr("class", "axis")
        .attr("transform", "translate(40,0)")
        .call(yearAxis)

      maxPerState = for year, states of data
        counts = (count for state, count of states)
        d3.max counts

      fill = (year) ->
        if year
          shows = data[year]
          (d) ->
            state = d.properties.name
            scale = colors.scale()
            maxShows = d3.max maxPerState
            scale.domain([0, maxShows]) shows[state]

      d3.json "/states.json", (json) ->
        map = g.selectAll("path")
         .data(json.features)
         .enter()
         .append("path")
         .attr("d", path)
         .attr('id', (state) -> state.properties.name)
         .attr('fill', (d) -> lightest)
         .on("click", click)

        transitionTo = (year) ->
          map.attr('fill', -> '#fff')
          map.transition()
           .attr('fill', fill(year))
           .duration(500)

        axis.selectAll('text')
          .on 'mouseover', (d) ->
            year = $(@).text()
            transitionTo year

        transitionTo '1995'

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

window.Map.Colors = class extends Colors
  range: [
    "#ffbaad", "#ff745c", "#ff401f", "#ff2f0a", "#f52500",
    "#e02200", "#cc1f00", "#b81c00", "#a31800", "#8f1500"
  ]
