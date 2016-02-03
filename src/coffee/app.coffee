parentEl = 'div#vv-dataviz-starter
'data = null
width = 0
height = 0
mapZoom = 0
margin = {}

# Create a categorical scale with Vocativ's dataviz colors
vocCatScale = d3.scale.ordinal().range(['#4f5c6d', '#77565a', '#9d5048', '#c54936','#ec4524'])

$(window).load -> onLoad()

onLoad = ->
  pymChild = new pym.Child { polling: 500 }
  setDimensions()
  ###
  # Load data from CSV

  d3.csv 'data/DATA.csv', (csvdata) ->
    data = csvdata
    cleanData()
  ###

  # Load data from google sheets
  Tabletop.init {
    key: '1l9ADP29P5u93GW4L9OFLtwF44bNn_uJ7wbpq8k7Pi1Q'
    simpleSheet: true
    callback: (jsondata, tabletop) ->
      data = jsondata
      # If you have multiple worksheets, make `simpleSheet: false`
      # If simpleSheet is false, specify the sheet to use below
      #data = data['Worksheet'].elements
      cleanData()
  }

cleanData = ->
  if data isnt null
    console.log 'Data ->', data
    vizData()
  else
    'No data'

vizData = ->
  $parentEl = $(parentEl)
  $parentEl.empty()

  # Basic D3 visualization skeleton
  svg = d3.select(parentEl)
    .append('svg')
      .attr('id', 'viz-svg')
      .attr
        width: width
        height: height
    .append('g')
      .attr('transform', 'translate('+margin.left+','+margin.top+')')
  
  svg.append('rect')
    .attr {
      width: width - ( margin.left + margin.right )
      height: height - ( margin.top + margin.bottom )
      fill: vocCatScale(1)
      x: 10
      y: 10
    }
  
  
setDimensions = ->
  $parentEl = $(parentEl)
  width = $parentEl.width() #500
  height = width * 0.6

  # Mobile / Desktop breakpoints
  if width > 649
    console.log width + 'px ==> Desktop'
    mobile = false
    mapZoom = 900
    margin =
      left: 16
      right: 16
      top: 16
      bottom: 16
  else
    console.log width + 'px ==> Mobile'
    mobile = true
    mapZoom = 400
    margin =
      left: 4
      right: 4
      top: 4
      bottom: 4

# Example GA completion event
#ga 'Items', 'finished-interactive', 'INTERACTIVE--PROJECT--NAME', 1
#$(window).click ->
  # Example GA interaction event
  #ga 'Items', 'click-interactive', 'DESCRIPTION--OF--CLICK', 1