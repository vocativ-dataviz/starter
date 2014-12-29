# Example GA interaction event
#ga 'Items', 'click-interactive', 'DESCRIPTION--OF--CLICK', 1

# Example GA completion event
#ga 'Items', 'finished-interactive', 'INTERACTIVE--PROJECT--NAME', 1


$(document).click ->
  ga 'Items', 'click-interactive', 'DESCRIPTION--OF--CLICK', 1



# Create a categorical scale with Vocativ's dataviz colors
vocCatScale = d3.scale.ordinal()
  .range(['#FB514E', '#2d82ca', '#49af37', '#9065c8'])

colorScaleColors = ['#e6e6e6','#FF0000']

data = null
vizScale = null
developmentMode = null
#numberFormat = d3.format('.3s') # Turns 24000 into '24.0k'
numberFormat = d3.format('s') # For no decimals

uri = new URI(window.location)
urlQuery = uri.search true # Returns key-value pairs for URL queries

if urlQuery.development is 'true'
  developmentMode = true
else
  developmentMode = false

# Load data from CSV
###
d3.csv 'data/PunitivenessByState.abbr.csv', (csvdata) ->
  data = csvdata
  vizData()
###

$(window).load ->
  # Set up the pymChild, so that everytime the iframe is resized
  # the renderCallback function is called repeatedly
  # (so it needs to clear and re-render, not append)

  pymChild = new pym.Child {
    polling: 500
  }

  if urlQuery.key isnt undefined
    sheetKey = urlQuery.key
  else
    sheetKey = '1EpP7dXXGWKEb91uumBDgKBr5jHY0O4U6S4T37L88ua4'

  simpleSheetVal = null

  if urlQuery.sheet is undefined
    simpleSheetVal = true
  else
    simpleSheetVal = false

  Tabletop.init {
    key: sheetKey
    simpleSheet: simpleSheetVal
    callback: (jsondata, tabletop) ->
      console.log 'rawsheetdata', jsondata
      #data = jsondata#.Data.elements
      if urlQuery.sheet isnt undefined
        sheetName = decodeURI(urlQuery.sheet)
        data = jsondata[sheetName].elements
      else
        data = jsondata

      vizData()
  }

###
$(window).resize ->
  console.log 'resizing, redrawing'
  vizData()
###

vizData = ->
  parentEl = '#content'
  $parentEl = $(parentEl)

  # This assumes there is a global 'data' var with our data
  console.log 'Our data!', data, data[data.length-1]

  width = $parentEl.width()
  height = $parentEl.height()

  vizScaleOrig = 900

  # Mobile / Desktop breakpoints
  if width > 649
    ###########
    # Desktop #
    ###########
    console.log width, ' ==> Desktop'
    mobile = false
    vizScale = vizScaleOrig

    margin =
      left: 16
      right: 16
      top: 16
      bottom: 16
  else
    ###########
    #  Mobile #
    ###########
    console.log width, ' ==> Mobile'
    mobile = true
    vizScale = ( vizScaleOrig * 0.4 )

    margin =
      left: 2
      right: 2
      top: 8
      bottom: 8

  # Rewrite height/width with margins for visualization
  height = height - margin.top - margin.bottom
  width = width - margin.left - margin.right

  stateData = {}


  if urlQuery.metric is undefined
    vizMetric = 'atorbelowminimumwagepercapita'
  else
    vizMetric = urlQuery.metric

  data.forEach (d) ->
    #console.log 'foreach d', d, d[vizMetric]
    stateData[d.stateabbr] = d[vizMetric]

  console.log 'we built stateData! ', stateData

  metricExtent = d3.extent d3.entries(data), (d) ->
    +d.value[vizMetric]

  #console.log 'metricExtent', metricExtent

  metricColorScale = d3.scale.linear()
    #.interpolate d3.interpolateLab
    .domain metricExtent
    .range colorScaleColors


  # Make option selector for metrics
  if developmentMode is true
    dataKeys = _.keys(data[0])
    #console.log 'dataKeys', dataKeys

    keySelector = d3.select(parentEl)
      .append('select')
      .attr('id', 'key-selector')

    keySelector.selectAll('option')
      .data dataKeys
      .enter().append('option')
      .attr 'value', (d,i) -> d
      .text (d,i) -> d
      .attr 'selected', (d,i) ->
        if vizMetric isnt undefined
          if d is vizMetric
            return 'selected'

    keySelector.on 'change', ->
      vizMetric = $(this).val()
      console.log 'changed to ', vizMetric
      window.location.href = uri.setSearch('metric', vizMetric).toString()

  # Basic D3 visualization skeleton
  svg = d3.select('#viz-svg').append('svg')
    .attr
      width: width + margin.left + margin.right
      height: height + margin.top + margin.bottom
      preserveAspectRatio: 'xMidYMid'
      viewBox: '0 0 '+width+' '+height


  if developmentMode is true
    $('#viz-metric').text vizMetric
    svg.append('text').text vizMetric
      .attr
        'font-size': 9
        'fill': '#CCC'
        'x': 2

    svg.style 'border', '1px solid #999'


  svg = svg.append('g').attr('transform', 'translate(10,10)')
    .attr 'transform', 'translate('+margin.left + ',' + margin.top + ')'


  legend = svg.append('g').attr('class', 'viz-legend')

  gradientId = 'legend-gradient'

  defs = legend.append('defs').append('linearGradient')
    .attr
      id: gradientId
      x1: '0%'
      x2: '100%'
      y1: '0%'
      y2: '0%'

  defs.append('stop')
    .attr
      'class': 'stop1'
      'offset': '0%'
      'stop-color': colorScaleColors[0]

  defs.append('stop')
    .attr
      'class': 'stop2'
      'offset': '100%'
      'stop-color': colorScaleColors[1]

  ###
  legend.append('rect')
    .attr
      fill: 'url(#'+gradientId+')'
      x: 50
      y: -2
      width: ( width * 0.8 )
      height: 20

  legend.append('text')
    .text(numberFormat(metricExtent[1]))
    .attr
      x: width-45
      y: 14
    .style 'text-anchor', 'end'

  legend.append('text')
    .text(numberFormat(metricExtent[0]))
    .attr
      x: 45
      y: 14
    .style 'text-anchor', 'end'
  ###

  legend.append('rect')
    .attr
      fill: 'url(#'+gradientId+')'
      x: ( width * 0.15 )
      y: -2
      width: ( width * 0.69 )
      height: 20

  legend.append('text')
    .text(numberFormat(metricExtent[1]))
    .attr
      x: width - ( width * 0.15 ) + 6
      y: 14
    .style 'text-anchor', 'start'

  legend.append('text')
    .text(numberFormat(metricExtent[0]))
    .attr
      x: ( width * 0.15 ) - 6
      y: 14
    .style 'text-anchor', 'end'

  ###
  tip = d3.tip()
    .attr('class', 'd3-tip')
    .html (d) ->
      #pos = d3.mouse(this)
      #tooltip.attr 'transform', 'translate('+pos[0]+','+pos[1]+')'
      stateAbbr = d.properties['STATE_ABBR']

      tipData = stateData[stateAbbr]

      tipNumberFormat = d3.format(",d")

      if tipData isnt undefined
        if tipNumberFormat(tipData) isnt ''
          tooltipText = '<h4>'+stateAbbr + '</h4> <p><strong>' + tipNumberFormat(tipData) + '</strong>'
        else
          tooltipText = '<h4>'+stateAbbr + '</h4> <p><strong>' + tipData + '</strong>'

        tooltipText += '<br><small>'

        if urlQuery.labeltext isnt undefined
          tooltipText += ' '+urlQuery.labeltext

        tooltipText += '</small></p>'
      else
        tooltipText = stateAbbr

      tooltipText

  svg.call tip
  ###

  d3.json 'data/USA.json', (us) ->

    $('#content').css('background-image', '')

    subunits = topojson.feature(us, us.objects.usStates)

    projection = d3.geo.albersUsa()
      .scale vizScale
      .translate [width/2, height/2]

    path = d3.geo.path()
      .projection(projection)

    svg.append('path')
      .datum(subunits)
      .attr 'd', d3.geo.path().projection(projection)

    states = svg.selectAll('.state')
      .data(topojson.feature(us, us.objects.usStates).features)
    .enter().append('path')
      .attr('class', (d) ->
        #console.log 'Dee!', d
        'state '+d.properties['STATE_ABBR']
      )
      .attr 'id', (d,i) -> d.properties['STATE_ABBR']
      .attr('d', path)
      .style 'stroke', 'white'
      .style 'stroke-width', 1
      .style 'fill', 'white'
      .style 'fill', (d,i) ->
        state = d.properties['STATE_ABBR']
        #console.log 'statedata!', state, stateData[d.properties['STATE_ABBR']]

        #metricColorScale +stateData[d.properties['STATE_ABBR']]
        thisStateData = stateData[d.properties['STATE_ABBR']]
        console.log 'state!', state, thisStateData
        if thisStateData isnt undefined
          if thisStateData is 'x'
            'red'
          else
            '#CCC'
      #.on 'mouseover', tip.show
      #.on 'mouseout', tip.show
    ###
      .on 'mouseover', -> tooltip.style 'display', null
      .on 'mouseout', -> tooltip.style 'display', 'none'
      .on 'mousemove', (d,i) ->
        pos = d3.mouse(this)
        stateAbbr = d.properties['STATE_ABBR']
        tooltip.attr 'transform', 'translate('+pos[0]+','+pos[1]+')'
        tipData = stateData[stateAbbr]

        if tipData isnt undefined
          tooltipText = stateAbbr + ' ' + numberFormat(tipData)
        else
          tooltipText = stateAbbr

        tooltip.select('.tooltip-text').text (d,i) ->
          tooltipText

    tooltip = svg.append('g')
      .attr('class', 'tooltip')
      .style('display', 'none')

    tooltip.append('text')
      .attr 'class', 'tooltip-text'
      .attr
        x: -10
        y: -12
        dy: '0.35em'
      .style
        'text-anchor': 'middle'
    ###