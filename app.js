var data, height, mapZoom, margin, parentEl, vizData, vocCatScale, width;

vocCatScale = d3.scale.ordinal().range(['#FB514E', '#2d82ca', '#49af37', '#9065c8']);

data = null;

width = 0;

height = 0;

mapZoom = 0;

margin = {};

parentEl = '#viz-content';


/*
d3.csv 'data/PunitivenessByState.abbr.csv', (csvdata) ->
  data = csvdata
  vizData()
 */

Tabletop.init({
  key: '1lybwOFxN5EBlwZhv_glwPFhPQDS9Ntr19YMSFa2JcTg',
  simpleSheet: false,
  callback: function(jsondata, tabletop) {
    data = jsondata;
    data = data['USE ME'].elements;
    return vizData();
  }
});

$(window).load(function() {
  var pymChild;
  return pymChild = new pym.Child({
    polling: 500
  });
});

vizData = function() {
  var $parentEl, controls, convictionControls, crimeControls, mobile, page, sourceControls, stories;
  $parentEl = $(parentEl);
  $parentEl.empty();
  if (data !== null) {
    console.log('Our data!', data);
  }
  width = $parentEl.width();
  height = width * 0.6;
  if (width > 649) {
    console.log(width, ' ==> Desktop');
    mobile = false;
    margin = {
      left: 16,
      right: 16,
      top: 16,
      bottom: 16
    };
    mapZoom = 900;
  } else {
    console.log(width, '==> Mobile');
    mobile = true;
    margin = {
      left: 4,
      right: 4,
      top: 4,
      bottom: 4
    };
    mapZoom = 400;
  }
  page = d3.select(parentEl);
  controls = d3.select('#viz-controls');
  sourceControls = controls.select('#source');
  crimeControls = controls.select('#crime');
  convictionControls = controls.select('#conviction');
  convictionControls.append('button').text('Conviction Reversed').on('click', function() {
    return $parentEl.isotope({
      filter: '.reversed'
    });
  });
  convictionControls.append('button').text('Conviction Affirmed').on('click', function() {
    return $parentEl.isotope({
      filter: '.notreversed'
    });
  });
  sourceControls.append('button').text('War').on('click', function() {
    return $parentEl.isotope({
      filter: '.war'
    });
  });
  sourceControls.append('button').text('Abuse').on('click', function() {
    return $parentEl.isotope({
      filter: '.abuse'
    });
  });
  crimeControls.append('button').text('Assault').on('click', function() {
    return $parentEl.isotope({
      filter: '.assault'
    });
  });
  crimeControls.append('button').text('Murder').on('click', function() {
    return $parentEl.isotope({
      filter: '.murder'
    });
  });
  stories = page.selectAll('div.story').data(data).enter().append('div').attr('class', function(d, i) {
    var classString;
    classString = 'story';
    if (d.reversed === 'y') {
      classString += ' reversed';
    } else {
      classString += ' notreversed';
    }
    classString += ' ' + d.cleantypeofcrime;
    classString += ' ' + d.cleanptsdsource;
    return classString;
  });
  stories.append('h4').text(function(d, i) {
    return d.casename;
  });
  stories.append('small').text(function(d, i) {
    return 'Year: ' + d.year;
  });
  stories.append('p').text(function(d, i) {
    return 'Reversed: ' + d.reversed;
  }).style({
    'color': function(d, i) {
      if (d.reversed === 'y') {
        return 'green';
      } else {
        return 'red';
      }
    }
  });
  stories.append('p').text(function(d, i) {
    return 'PTSD Source: ' + d.ptsdsource;
  }).style('font-weight', 'bold');
  stories.append('div').text(function(d, i) {
    return d.whathappenedsummary;
  });
  $parentEl.isotope({
    layoutMode: 'masonry'
  });
  return console.log('yo');
};
