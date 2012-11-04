#= require 'vendor/d3.v2.min'
#= require 'timeline'

$ ->
  timeline = new Timeline
  timeline.render
    width: $(document).width()
    height: $(document).height()
    selector: '#nav'

  map = new Map
  map.render
    width: $('#map').width()
    height: $('#map').height()
    selector: '#map'

window.Log = (obj) ->
  console.log JSON.stringify(obj, undefined, 4)

window.Map = class Map
  projection: ->
    d3.geo.albersUsa()
      .scale(@options.width)
      .translate([0,0])

  path: ->
    d3.geo.path().projection @projection()

  svg: ->
    d3.select(@options.selector)
      .append('svg')
      .attr('width', @options.width)
      .attr('height', @options.height)

  render: (@options) ->
    width = @options.width
    height = @options.height
    padding = 30

    projection = @projection()

    path = @path()
    svg = @svg()

    svg.append("rect")
       .attr("class", "background")
       .attr("width", width)
       .attr("height", height)

    g = svg.append("g")
           .attr("transform", "translate(#{width / 2 + 44},#{height / 2})")
           .append("g").attr("id", "states")

    d3.json '/shows.json', (json) ->
      data = d3.nest()
        .key((d) -> d.year)
        .key((d) -> d.state)
        .rollup((d) -> d.length)
        .map(json)

      colors = new Map.Colors
      lightest = colors.lightest()

      years = new Map.Years
        years: d3.keys(data)
        padding: padding
        height: $(document).height()
        colors: colors
        width: $(document).width()

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
         .style('fill', (d) -> lightest)

        transition = (fill, callback) ->
          map.transition()
           .style('fill', fill)
           .duration(250)
           .each('end', callback)

        transitionTo = (year) ->
          transition lightest, ->
            transition fill(year)

        axis = years.render()
        axis.selectAll('text')
          .on 'mouseover', (d) ->
            year = $(@).text()
            transitionTo year

        transitionTo '1995'

window.Map.Colors = class extends Colors
  range: [
    "#ffbaad", "#ff745c", "#ff401f", "#ff2f0a", "#f52500",
    "#e02200", "#cc1f00", "#b81c00", "#a31800", "#8f1500"
  ]

window.Map.Years = class Years
  constructor: (options={}) ->
    @years = options['years']
    @padding = options['padding']
    @height = options['height']
    @width = options['width']
    @colors = options['colors']

  path: ->
    d3.select('#yearsControl')
      .append('svg')
      .attr('width', @width)
      .attr 'height', @height

  first: ->
    d3.first @years

  last: ->
    d3.last @years

  yScale: ->
    d3.scale.linear()
      .domain([@first(), @last()])
      .range([@padding, @height - (@padding * 2)])

  axis: ->
    d3.svg.axis()
      .scale(@yScale())
      .orient("right")
      .ticks(@years.length)
      .tickFormat (d) -> d

  render: ->
    @path().append("g")
      .attr('fill', => @colors.lightest())
      .attr("class", "axis")
      .attr("transform", => "translate(#{(@width / 2)},#{@padding / 2})")
      .call(@axis())
