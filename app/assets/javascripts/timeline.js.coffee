$ ->
  timeline = new Timeline
  timeline.render
    width: $(document).width()
    height: $(document).height()
    selector: '#nav'


window.Rings = class Rings
  @map: [
    { innerRadius:   0, outerRadius: .10 }
    { innerRadius: .20, outerRadius: .60 }
    { innerRadius: .66, outerRadius: .95 }
  ]

  @for: (radius) ->
    radiusScale = d3.scale.linear().range([0,radius]).domain([0,1])
    new @ radiusScale

  constructor: (@radiusScale) ->

  angleScale:  d3.scale.linear().range([0, 2 * Math.PI])

  startAngle:  (d) => Math.max 0, Math.min(2 * Math.PI, @angleScale(d.x))
  endAngle:    (d) => Math.max 0, Math.min(2 * Math.PI, @angleScale(d.x + d.dx))
  innerRadius: (d) => @radiusScale Rings.map[d.depth].innerRadius
  outerRadius: (d) => @radiusScale Rings.map[d.depth].outerRadius

  arc: ->
    d3.svg.arc()
      .startAngle(@startAngle)
      .endAngle(@endAngle)
      .innerRadius(@innerRadius)
      .outerRadius(@outerRadius)

  arcTween: (d) ->
    arc = @arc()
    scale = @angleScale
    xd = d3.interpolate(scale.domain(), [d.x, d.x + d.dx])
    (d, i) ->
      if i then (t) -> arc d
      else (t) ->
        scale.domain xd(t)
        arc d

window.Colors = class Colors
  range: [
    "#ffdcd6", "#ffcbc2", "#ffbaad", "#ffa899", "#ff9785", "#ff8670",
    "#ff745c", "#ff6347", "#ff5233", "#ff401f", "#ff2f0a", "#f52500",
    "#e02200", "#cc1f00", "#b81c00", "#a31800", "#8f1500"
  ]

  darkest: ->
    @range[@range.length-1]

  scale: ->
    d3.scale.quantize().range @range

  fill: ->
    scale = @scale()
    darkestColor = @darkest()
    (d) ->
      maxShows = if d.parent
        d3.max d.parent.children, (d) -> d.size
      else
        d3.max d.children, (d) -> d.size

      if d.depth == 0
        darkestColor
      else
        scale.domain([1, maxShows]) d.size

window.Timeline = class Timeline
  radius: ->
    Math.min(@options.width, @options.height) / 2

  svg: ->
    d3.select(@options.selector)
      .append('svg')
      .attr('width', @options.width)
      .attr('height', @options.height)
      .append("g")
      .attr("transform", "translate(#{@radius()},#{@options.height / 2})")

  partition: ->
    d3.layout.partition()
      .sort (a,b) ->
        d3.ascending a.sortKey, b.sortKey
      .value (d) -> d.size

  render: (@options) ->
    colors = new Colors
    rings = Rings.for @radius()

    svg = @svg()
    partition = @partition()

    d3.json "/timelines", (json) ->
      click = (d) ->
        if d.children
          path.transition().duration(750).attrTween "d", rings.arcTween(d)

      hover = (d) ->
        $('#meta').text d.name

      path = svg.data([json])
        .selectAll('path')
        .data(partition.nodes)
        .enter()
        .append('path')
        .attr('d', rings.arc())
        .attr('stroke', colors.darkest())
        .attr('data-value', (d) -> d.value)
        .attr('title', (d) -> d.name)
        .on('click', click)
        .on('mouseover', hover)
        .style "fill", colors.fill()
