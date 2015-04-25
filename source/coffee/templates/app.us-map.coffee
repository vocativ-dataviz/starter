charts.mapUSData = ->
  # Rewrite height/width with margins for visualization
  #height = height - margin.top - margin.bottom
  #width = width - margin.left - margin.right

  stateData = {}
  colorScaleColors = ['#CCC', vocCatScale(1)]
  numberFormat = d3.format(',d')

  vizMetric = 'metric'

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

  # Basic D3 map skeleton
  # Using preserveAspectRatio and viewBox
  # to make the map responsive
  svg = d3.select(parentEl).append('svg')
    .attr
      width: width + margin.left + margin.right
      height: height + margin.top + margin.bottom
      preserveAspectRatio: 'xMidYMid'
      viewBox: '0 0 '+width+' '+height

  svg = svg.append('g')
    .attr 'transform', 'translate('+margin.left + ',' + margin.top + ')'

  ###
  tip = d3.tip()
    .attr('class', 'd3-tip')
    .html (d) ->
      'Hello world!'
  svg.call tip
  ###
  

  d3.json 'data/USA.json', (us) ->

    $('#content').css('background-image', '')

    subunits = topojson.feature(us, us.objects.usStates)

    projection = d3.geo.albersUsa()
      .scale mapZoom
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
        thisStateData = stateData[d.properties['STATE_ABBR']]

        # For a numerical map
        metricColorScale +thisStateData
        
        ###
        # For a categorical map
        if thisStateData isnt undefined and thisStateData isnt ''
          vocCatScale thisStateData
        else
          '#CCC'
        ###
        

    makeLegend = ->
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

    makeLegend()
