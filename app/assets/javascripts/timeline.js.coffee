$ ->
  timeline = $('#timeline')
  width = $(document).width()
  height = $(document).height()
  radius = (Math.min(width, height) / 2)
  colors = [
    "#ffdcd6", "#ffcbc2", "#ffbaad", "#ffa899", "#ff9785", "#ff8670",
    "#ff745c", "#ff6347", "#ff5233", "#ff401f", "#ff2f0a", "#f52500",
    "#e02200", "#cc1f00", "#b81c00", "#a31800", "#8f1500"
  ]
  darkestColor = colors[colors.length-1]

  svg = d3.select('#timeline')
          .append('svg')
          .attr('width', width)
          .attr('height', height)
          .append("g")
          .attr("transform", "translate(" + width / 2 + "," + height / 2 + ")")

  partition = d3.layout.partition()
  partition.sort (a,b) ->
    d3.ascending a.sortKey, b.sortKey
  partition.value (d) -> d.size

  angleScale  = d3.scale.linear().range([0, 2 * Math.PI])
  radiusScale = d3.scale.linear().range([0,radius]).domain([0,1])

  ringMap = [
    { innerRadius: radiusScale(0), outerRadius: radiusScale(.10) }
    { innerRadius: radiusScale(.20), outerRadius: radiusScale(.60) }
    { innerRadius: radiusScale(.66), outerRadius: radiusScale(.95) }
  ]

  arc = d3.svg.arc()
    .startAngle((d) -> angleScale(d.x))
    .endAngle((d) -> angleScale(d.x + d.dx))
    .innerRadius((d) -> ringMap[d.depth].innerRadius)
    .outerRadius((d) -> ringMap[d.depth].outerRadius)

  d3.json "/timelines", (json) ->
    maxShowsPerYear = d3.max json.children, (d) -> d.size
    colorScale = d3.scale.quantize().domain([1, maxShowsPerYear]).range colors

    g = svg.data([json])
           .selectAll('path')
           .data(partition.nodes)
           .enter()
           .append('path')
           .attr('d', arc)
           .attr('stroke', darkestColor)
           .attr('data-value', (d) -> d.value)
           .attr('title', (d) -> d.name)
           .style "fill", (d) ->
             if d.depth == 0
               darkestColor
             else
               colorScale d.size
