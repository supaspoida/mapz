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

  svg = d3.select('#timeline')
          .append('svg')
          .attr('width', width)
          .attr('height', height)
          .append("g")
          .attr("transform", "translate(" + width / 2 + "," + height / 2 + ")")

  partition = d3.layout.partition()
  partition.size([2 * Math.PI, radius * radius])
  partition.sort (a,b) ->
    d3.ascending a.sortKey, b.sortKey
  partition.value (d) -> d.size

  scale = d3.scale.linear().range([0,radius]).domain([0,1])

  ringMap = [
    { innerRadius: scale(0), outerRadius: scale(0) }
    { innerRadius: scale(.20), outerRadius: scale(.60) }
    { innerRadius: scale(.65), outerRadius: scale(.95) }
  ]

  arc = d3.svg.arc()
    .startAngle((d) -> d.x)
    .endAngle((d) -> d.x + d.dx)
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
           .attr("display", (d) -> "none" if d.depth == 0)
           .attr('stroke', colors[colors.length-1])
           .attr('data-value', (d) -> d.value)
           .attr('title', (d) -> d.name)
           .style "fill", (d) -> colorScale(d.size)
