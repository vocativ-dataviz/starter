# Vocativ Dataviz Template/Starter

A lightweight starting point to create interactive visualizations of data. Of all sorts. (Maps, charts, graphs, tools)

## Use
First `npm install`

To run **/gulpfile.js**, from the root of the project use `npm start` or `gulp`

The files in **/html/** can contain mustache templates. The variables for those templates are defined in **options** var in the **/gulpfile.js** file.

```
var options = {
    'org': 'Vocativ',
    'host': 'localhost',
    'port': 8888,
    'projName': 'Project Name',
    'gaCode': 'UA-XXXX-Y',
    'aws': {
        'key': process.env.AWS_KEY,
        'secret': process.env.AWS_SECRET,
        'bucket': 'interactives'
    }
}
```

The master style / CSS file is **/stylus/style.styl**, all other .styl files need to be included with **@import** in style.styl to be compiled into the final style.css file.


#### What gulpfile.js does
+ **/html/** is compiled into **/build/index.html**
+ **/stylus/style.styl** is compiled into **build/style.css**
+ **/coffee/** is compiled into **/build/**
+ **/vendor/** is compiled into **/build/vendor.js**
+ Minifies CSS
+ Uglifies JS (vendor and compiled CoffeeScript)
+ Watches all files and compiles them on change
+ Starts a local webserver at ___localhost:8888___
+ Deploy /build/ to gh-pages with `gulp github`

## Gulp Packages
[Found in Package.json](https://github.com/Vocativ/dataviz-starter/blob/master/package.json)

## Technologies / Libraries used
+ [CoffeeScript](http://coffeescript.org/)
+ [Stylus](http://learnboost.github.io/stylus/)
+ [D3](http://d3js.org/)
+ [jQuery](http://jquery.com/)
+ [Underscore](http://underscorejs.org/)
+ [Gulp](http://gulpjs.com/)
+ [Pym](http://blog.apps.npr.org/pym.js/)

## This template/starter needs to make sure the following is built-in
* [ ] Change the URL for each 'section/step' of the interactive so back button works
* [ ] Allow the user to link to and share specific sections/insights in the interactive
* [x] Report events to Google Analytics, including clicks on the page, as well as a 'completion' event to be fired when all sections are viewed, or interactive is otherwise 'completed'
* [x] Have visualization respond to breakpoints (ie show less data on mobile, or use smaller padding/margin sizes)
* [x] Include Vocativ house styles such as colors, buttons, and fonts
* [x] Pull in data from google sheets, if the reporter's data is there
* [x] Have Pym.js set up (and the structure required for that) so that the piece is easily embeddable in WordPress as a resizable iframe


## To-do
* [ ] Add [gulp-json-lint](https://www.npmjs.org/package/gulp-json-lint)
* [ ] Add [gulp-uncss](https://www.npmjs.org/package/gulp-uncss)
* [x] Add Google [Analytics JS / tracking code](https://developers.google.com/analytics/devguides/collection/analyticsjs/)
* [x] Add [gulp-gh-pages](https://github.com/rowoot/gulp-gh-pages)
* [x] Add GA custom [interaction events](https://developers.google.com/analytics/devguides/collection/analyticsjs/events)
```
Interaction Events

category: Items
action: click-interactive
opt_label: DESCRIPTIVE-OF-CLICK
opt_value: 1
opt_noninteraction: false

where DESCRIPTIVE-OF-CLICK = Healthcare, Employment, Schools, etc - should be text the uniquely describes the button or element clicked

category: Items
action: finished-interactive
opt_label: DESCRIPTIVE-OF-INTERACTIVE
opt_value: 1
opt_noninteraction: false


where DESCRIPTIVE-OF-INTERACTIVE = Transgender-Rights-Map, etc - should be text the uniquely describes the interactive element that user finished the interaction with
```