# Vocativ Interactive Dataviz Template/Starter

A lightweight starting point to create interactive visualizations of data. Of all sorts. (Maps, charts, graphs, tools)

jQuery, D3, and Underscore are included. [Stylus](http://learnboost.github.io/stylus/) is used for CSS.

I've focused on sane defaults (for me) and little else, so it can be the starting point for as many projects as possible with little to no modification.

## Gulp Packages
+ [gulp-stylus](https://www.npmjs.org/package/gulp-stylus)
+ [gulp-coffee](https://www.npmjs.org/package/gulp-coffee)
+ [gulp-coffeelint](https://www.npmjs.org/package/gulp-coffeelint)
+ [gulp-concat](https://www.npmjs.org/package/gulp-concat)

## Technologies / Libraries used
+ [Coffeescript](http://coffeescript.org/)
+ [Stylus](http://learnboost.github.io/stylus/)
+ [D3](http://d3js.org/)
+ [jQuery](http://jquery.com/)
+ [Underscore](http://underscorejs.org/)
+ [Gulp](http://gulpjs.com/)
+ [Pym](http://blog.apps.npr.org/pym.js/)


## This template/starter needs to make sure the following is built-in
+ Change the URL for each 'section/step' of the interactive so back button works
+ Allow the user to link to and share specific sections/insights in the interactive
+ Pull in data from google sheets, if the reporter's data is there
+ Report events to Google Analytics, including clicks on the page, as well as a 'completion' event to be fired when all sections are viewed, or interactive is otherwise 'completed'
+ Have PYM.js set up (and the structure required for that) so that the piece is easily embeddable in WordPress as a resizable iframe 
+ Have visualization respond to breakpoints (ie show less data on mobile, or use smaller padding/margin sizes)
+ Include Vocativ house styles such as colors, buttons, and fonts