$ ->
  # Interpolate the scales!
  arcTween = (d) ->
    xd = d3.interpolate(x.domain(), [d.x, d.x + d.dx])
    yd = d3.interpolate(y.domain(), [d.y, 1])
    yr = d3.interpolate(y.range(), [(if d.y then 20 else 0), radius])
    (d, i) ->
      (if i then (t) ->
        arc d
       else (t) ->
        x.domain xd(t)
        y.domain(yd(t)).range yr(t)
        arc d
      )

  width = $(document).width()
  height = $(document).height()

  radius = Math.min(width, height) / 2
  x = d3.scale.linear().range([0, 2 * Math.PI])
  y = d3.scale.sqrt().range([0, radius])
  colors = [
    "#ffdcd6", "#ffcbc2", "#ffbaad", "#ffa899", "#ff9785", "#ff8670",
    "#ff745c", "#ff6347", "#ff5233", "#ff401f", "#ff2f0a", "#f52500",
    "#e02200", "#cc1f00", "#b81c00", "#a31800", "#8f1500"
  ]

  color = d3.scale.quantize().domain([1,162]).range colors

  vis = d3.select("#chart")
          .append("svg")
          .attr("width", width)
          .attr("height", height)
          .append("g")
          .attr("transform", "translate(" + width / 2 + "," + height / 2 + ")")

  partition = d3.layout.partition()
                       .value((d) -> d.size)
                       .sort (a,b) ->
                          d3.ascending a.sortKey, b.sortKey

  arc = d3.svg.arc()
              .startAngle((d) -> Math.max 0, Math.min(2 * Math.PI, x(d.x)))
              .endAngle((d) -> Math.max 0, Math.min(2 * Math.PI, x(d.x + d.dx)))
              .innerRadius((d) -> Math.max 0, y(d.y))
              .outerRadius((d) -> Math.max 0, y(d.y + d.dy))

  d3.json "/timelines", (json) ->
    click = (d) ->
      path.transition().duration(750).attrTween "d", arcTween(d)

    path = vis.data([json])
              .selectAll("path")
              .data(partition.nodes)
              .enter()
              .append("path")
              .attr("d", arc)
              .style("fill", (d) -> color(d.size))
              .on("click", click)
