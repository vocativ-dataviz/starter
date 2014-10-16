# Create a categorical scale with Vocativ's dataviz colors
vocCatScale = d3.scale.ordinal()
  .range(['#FB514E', '#2d82ca', '#49af37', '#9065c8'])

data = null

# Set up the pymChild, so that everytime the iframe is resized
# the renderCallback function is called repeatedly
# (so it needs to clear and re-render, not append)
pymChild = new pym.Child {
  renderCallback: vizData
}

# Load data from CSV
d3.csv 'data/PunitivenessByState.abbr.csv', (csvdata) ->
  data = csvdata

# When the document is ready, load the spreadsheet and
# feed it to vizData to map the data
$(document).ready ->
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

vizData = ->
  # This assumes there is a global 'data' var with our data
  console.log 'Our data!', data