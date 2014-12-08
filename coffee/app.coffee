# Create a categorical scale with Vocativ's dataviz colors
vocCatScale = d3.scale.ordinal()
  .range(['#FB514E', '#2d82ca', '#49af37', '#9065c8'])

data = null

# Load data from CSV
###
d3.csv 'data/PunitivenessByState.abbr.csv', (csvdata) ->
  data = csvdata
###

# When the document is ready, load the spreadsheet and
# feed it to vizData to map the data
###
$(window).load ->
  Tabletop.init {
    key: '16p8arXc4-Ynjl5tPJpiyqZTH_54rTktPaJaFkeJaKzI'
    simpleSheet: false
    callback: (jsondata, tabletop) ->
      data = jsondata
      vizData()
  }

$(window).resize ->
  console.log 'resizing, redrawing'
  vizData()
###

$(window).click ->
  # Example GA interaction event
  #ga 'Items', 'click-interactive', 'DESCRIPTION--OF--CLICK', 1

$(window).load ->
  pymChild = new pym.Child {
    renderCallback: vizData
    polling: 500
  }

  vizData()

vizData = ->
  parentEl = '#content'
  $parentEl = $(parentEl)

  if data isnt undefined
    console.log 'Our data!', data

  width = $parentEl.width() #500
  height = $parentEl.height() / 2 #500

  # Mobile / Desktop breakpoints
  if width > 649
    console.log width, ' ==> Desktop'
    mobile = false
    margin =
      left: 16
      right: 16
      top: 16
      bottom: 16
  else
    console.log width, '==> Mobile'
    mobile = true
    margin =
      left: 16
      right: 16
      top: 16
      bottom: 16

  # Example GA completion event
  #ga 'Items', 'finished-interactive', 'INTERACTIVE--PROJECT--NAME', 1

  # Basic D3 visualization skeleton
  svg = d3.select('#viz-svg')

  svg.attr
    width: width
    height: height

  svg.append('rect')
    .attr {
      width: width-10
      height: height-10
      fill: 'red'
      x: 10
      y: 10
    }
