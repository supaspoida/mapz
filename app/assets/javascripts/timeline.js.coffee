$ ->
  timeline = new Timeline
  timeline.render()

window.Timeline = class Timeline
  colors: [
    "#ffdcd6", "#ffcbc2", "#ffbaad", "#ffa899", "#ff9785", "#ff8670",
    "#ff745c", "#ff6347", "#ff5233", "#ff401f", "#ff2f0a", "#f52500",
    "#e02200", "#cc1f00", "#b81c00", "#a31800", "#8f1500"
  ]

  radius: (width, height) ->
    Math.min(width, height) / 2

  render: ->
    width = $(document).width()
    height = $(document).height()
    radius = @radius(width, height)
    colors = @colors
    darkestColor = colors[colors.length-1]

    svg = d3.select('#nav')
      .append('svg')
      .attr('width', width)
      .attr('height', height)
      .append("g")
      .attr("transform", "translate(#{radius},#{height / 2})")

    partition = d3.layout.partition()
      .sort (a,b) ->
        d3.ascending a.sortKey, b.sortKey
      .value (d) -> d.size

    angleScale  = d3.scale.linear().range([0, 2 * Math.PI])
    radiusScale = d3.scale.linear().range([0,radius]).domain([0,1])

    ringMap = [
      { innerRadius: radiusScale(0), outerRadius: radiusScale(.10) }
      { innerRadius: radiusScale(.20), outerRadius: radiusScale(.60) }
      { innerRadius: radiusScale(.66), outerRadius: radiusScale(.95) }
    ]

    arc = d3.svg.arc()
      .startAngle((d) -> Math.max 0, Math.min(2 * Math.PI, angleScale(d.x)))
      .endAngle((d) -> Math.max 0, Math.min(2 * Math.PI, angleScale(d.x + d.dx)))
      .innerRadius((d) -> ringMap[d.depth].innerRadius)
      .outerRadius((d) -> ringMap[d.depth].outerRadius)

    d3.json "/timelines", (json) ->
      colorScale = d3.scale.quantize().range colors

      click = (d) ->
        if d.children
          path.transition().duration(750).attrTween "d", arcTween(d)

      getColor = (d) ->
        maxShows = if d.parent
          d3.max d.parent.children, (d) -> d.size
        else
          d3.max d.children, (d) -> d.size

        if d.depth == 0
          darkestColor
        else
          colorScale.domain([1, maxShows]) d.size

      hover = (d) ->
        $('#meta').text d.name

      path = svg.data([json])
        .selectAll('path')
        .data(partition.nodes)
        .enter()
        .append('path')
        .attr('d', arc)
        .attr('stroke', darkestColor)
        .attr('data-value', (d) -> d.value)
        .attr('title', (d) -> d.name)
        .on('click', click)
        .on('mouseover', hover)
        .style "fill", getColor

    arcTween = (d) ->
      xd = d3.interpolate(angleScale.domain(), [d.x, d.x + d.dx])
      (d, i) ->
        if i then (t) -> arc d
        else (t) ->
          angleScale.domain xd(t)
          arc d

