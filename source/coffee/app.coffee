# Init variables with defaults
data = null
width = 0
height = 0
mapZoom = 0
margin = {}
parentEl = '#viz-content'

# Create a categorical scale with Vocativ's dataviz colors
vocCatScale = d3.scale.ordinal()
  .range(['#FB514E', '#2d82ca', '#49af37', '#9065c8'])

############################
# Options for loading data #
############################

# Load data from CSV
###
d3.csv 'data/PunitivenessByState.abbr.csv', (csvdata) ->
  data = csvdata
  vizData()
###

# Load data from google sheets
Tabletop.init {
  key: '1l9ADP29P5u93GW4L9OFLtwF44bNn_uJ7wbpq8k7Pi1Q'
  simpleSheet: true
  callback: (jsondata, tabletop) ->
    data = jsondata
    # If you have multiple worksheets, make `simpleSheet: false`
    # If simpleSheet is false, specify the sheet to use here
    #data = data['Schools'].elements
    vizData()
}


# Example GA completion event
#ga 'Items', 'finished-interactive', 'INTERACTIVE--PROJECT--NAME', 1

#$(window).click ->
  # Example GA interaction event
  #ga 'Items', 'click-interactive', 'DESCRIPTION--OF--CLICK', 1

$(window).load ->
  # Init PYM.js on page load
  pymChild = new pym.Child { polling: 500 }

vizData = ->
  $parentEl = $(parentEl)

  $parentEl.empty()

  if data isnt null
    console.log 'Our data!', data

  width = $parentEl.width() #500
  height = width * 0.6

  # Mobile / Desktop breakpoints
  if width > 649
    console.log width, ' ==> Desktop'
    mobile = false
    margin =
      left: 16
      right: 16
      top: 16
      bottom: 16
    mapZoom = 900
  else
    console.log width, '==> Mobile'
    mobile = true
    margin =
      left: 4
      right: 4
      top: 4
      bottom: 4
    mapZoom = 400

  #mapData()

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
      width: width-margin.left
      height: height-margin.top
      fill: vocCatScale(1)
      x: 10
      y: 10
    }
  

