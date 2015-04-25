# Vocativ Dataviz Template/Starter

A lightweight starting point to create interactive visualizations of data. Of all sorts (besides maps, which has it's own starter). (Charts, graphs, apps, tools)

## Getting Started
+ Clone starter `git clone https://github.com/Vocativ/dataviz-starter.git NEW-PROJECT`
+ Go to it `cd NEW-PROJECT`
+ Install dependencies from package.json `sudo npm install`
+ Make options.json based on **options.sample.json** `mv options.sample.json options.json`
+ `subl options.json` and **edit the project name and slug for your project**
+ Remove git history `gulp init`
+ Create new repo in GitHub web app
+ Add repo in GitHub desktop app, add GitHub URL as remote
+ `gulp`
+ Sometimes things don't work properly the first time around, if this happens, just `gulp` again
+ **Develop**
+ Want to show internally? `gulp github` and see it at <http://vocativ-dataviz.github.io/NEW-PROJECT/>
+ Ready to deploy? `gulp s3` and see it at <http://interactives.s3.amazonaws.com/NEW-PROJECT/>

## Application structure
This starter is a jumping-off-point for all sorts of different interactive dataviz. It tries to take care of all the things you don't want to think of so you can move quickly, but leaving enough room for anything to be possible.

#### /stylus/style.styl
The master style / CSS file is **/stylus/style.styl**, all other .styl files need to be included with **@import** in style.styl to be compiled into the final style.css file.

#### /mustache/partials/body.mustache
This is the only HTML file you need to be modifying, in most cases.

#### /coffee/app.coffee
This is the main file for the app, where initial variables are defined, data is loaded and cleaned, and the proper chart function to visualize the data is called. 

#### /coffee/templates/
These templates are ignored by default when .coffee files are compiled into **app.js**. To use any of these templates, move them down to the **/coffee/** folder. 

**app.coffee** sets up the data, and these templates define *charts.mapUSData()* or other future chart functions which visualize with that data.

#### /templates/app.us-map.coffee
+ Function defined: **charts.mapUSData()**
If you'd like to map some data, this file defines the US map function which automatically pulls data from the **data** variable. The code will need to be modified to switch between numerical and categorical choropleth maps.

## Maps
+ You can find a template for a categorical choropleth map here: <https://docs.google.com/spreadsheets/d/1cuVwb3ufNvTNgXCXeeOXTz5NEieZOsKx0tcmE7_30EM/edit?usp=sharing>
+ You can find a template for a global map here: <https://docs.google.com/spreadsheets/d/1oMRYb286BTn8TuHzUwtlpuBNVVF53jrhO0rE0oRbrS8/edit?usp=sharing>
+ You can find a template for a numerical choropleth map here: <https://docs.google.com/spreadsheets/d/1l9ADP29P5u93GW4L9OFLtwF44bNn_uJ7wbpq8k7Pi1Q/edit?usp=sharing>

# So you wanna deploy an interactive?
Follow this basic checklist!

- [ ] Has all of the copy been double-checked by Editorial?
- [ ] Is there a link to the data?
    - [ ] The original source?
    - [ ] A cleaned Google Spreadsheet? (Make sure it can't be edited)
- [ ] Is the piece deployed correctly?
    - [ ] The slug and host in **options.json** have been double-checked
    - [ ] /build/ has been deployed to S3
    - [ ] Is pym.js installed correctly in the post / CMS?
    - [ ] Is pym enabled properly in the app? (and called after load)
    - [ ] Is the post embed referencing Amazon S3 and *not GitHub*?
- [ ] Have the analytics & testing been set up properly?
    - [ ] Is the GA UA code defined in **options.json**?
    - [ ] Is the GA code set up properly in **mustache/partials/header.mustache**?
    - [ ] Does the page emit **interactive-click** events on click?
    - [ ] Is there a function in the app to trigger **finished-interactive**?
- [ ] Has the data been locked down?
    - [ ] If reporter-driven, have they given final approval?
    - [ ] If running off Google sheets, has it been converted to local JSON/CSV?
- [ ] Test it embedded inside the CMS, does everything work as expected?
- [ ] Does it work and look right at all screen sizes **in the CMS?**
    - [ ] Check at 640px (size of CMS desktop column)
    - [ ] Check at 320px (iPhone 3 portrait width)
    - [ ] Check at 1024px (basic desktop size)
    - [ ] What happens when you resize the window between 320 and 1024px?
    - [ ] Do all buttons/animations work on mobile?
- [ ] Share buttons?
    - [ ] Do they link to the correct page?
    - [ ] Do they have good share text/headlines in them?
    - [ ] Does each share button have share images attached with proper proportions?
- [ ] Has a share/poster image been created? (Large **screenshot.png** of the piece - share images and homepage images)
- [ ] Is everybody who worked on it credited in some way?

## Use
First `npm install` or perhaps `sudo npm install`

To run **/gulpfile.coffee** for development, from the root of the project use `npm start` or `gulp`

To deploy to gh-pages, run `gulp github`

To deploy to S3, run `gulp publish`

The files in **/mustache/** are mustache templates/partials. The variables for those templates are defined in **/options.json**


## What gulpfile.coffee does
+ `gulp init`: removes **.git** and moves **PROJECT_README.md** to **README.md** to initialize a new project
+ **/mustache/** is compiled into **/build/index.html**
+ **/stylus/style.styl** is compiled into **build/style.css**
+ **/coffee/** is compiled into **/build/app.js**
+ **/javascript/** is compiled into **/build/lib.js**
+ .png and .svg in **/img/** is optimized and moved to **/build/img/**
+ .json and .csv in **/data/** is moved to **/build/data/**
+ Minifies CSS
+ Uglifies JS (vendor and compiled CoffeeScript)
+ Watches all files and compiles them on change
+ Starts a local webserver at ___localhost:8888___
+ Deploy /build/ to gh-pages with `gulp github`
+ Deploy /build/ to S3 with `gulp s3`
+ Mirror /build/ on S3 and gh-pages with `gulp mirror`

## Gulp Packages
[Found in Package.json](https://github.com/vocativ-dataviz/starter/blob/master/package.json)

## Technologies / Libraries used
+ [CoffeeScript](http://coffeescript.org/)
+ [Stylus](http://learnboost.github.io/stylus/)
+ [D3](http://d3js.org/)
+ [jQuery](http://jquery.com/)
+ [Underscore](http://underscorejs.org/)
+ [Gulp](http://gulpjs.com/)
+ [Pym](http://blog.apps.npr.org/pym.js/)

### GA Interaction Events
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

# To-Do
Additions/changes to be made on this boilerplate/starter.
- [ ] Add [gulp-imagemin](https://github.com/sindresorhus/gulp-imagemin) to compress images and SVG
- [ ] Add [gulp-notify](https://github.com/mikaelbr/gulp-notify)
- [ ] Add [gulp-uncss](https://www.npmjs.com/package/gulp-uncss)