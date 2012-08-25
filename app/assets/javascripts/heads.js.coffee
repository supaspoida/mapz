$ ->
  width = $(document).width()
  height = $(document).height()

  d3.select('#heads').attr('width', width).attr('height', height)
