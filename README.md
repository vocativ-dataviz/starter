# Vocativ Dataviz Template/Starter

A lightweight starting point to create interactive visualizations of data. Of all sorts (besides maps, which has it's own starter). (Charts, graphs, apps, tools)

## Getting Started
+ Clone starter `git clone https://github.com/Vocativ/dataviz-starter.git NEW-PROJECT`
+ Go to it `cd NEW-PROJECT`
+ Install package.json `sudo npm install`
+ Make options.json based on **options.sample.json** `mv options.sample.json options.json`
+ Remove git history `gulp git-reset`
+ Create new repo in GitHub web app
+ Add repo in GitHub desktop app, add GitHub URL as remote
+ `gulp`
+ Develop
+ Want to show internally? `gulp github` and see it at <http://vocativ-dataviz.github.io/NEW-PROJECT/>
+ Ready to deploy? `gulp publish` and see it at <http://interactives.s3.amazonaws.com/NEW-PROJECT>

## Application structure
This starter is a jumping-off-point for all sorts of different interactive dataviz. It tries to take care of all the things you don't want to think of so you can move quickly, but leaving enough room for anything to be possible. 

#### app.coffee
This is the main file for the app, where initial variables are defined, data is loaded, and the proper function to visualize the data is called. 

#### map.coffee
If you'd like to map some data, this file defines the mapData() function which automatically pulls data from the **data** variable

## So you wanna deploy an interactive?
Follow this basic checklist!

- [ ] Has all of the copy been double-checked by Editorial?
- [ ] Is there a link to the data?
    - [ ] The original source?
    - [ ] A cleaned Google Spreadsheet? (Make sure it can't be edited)
- [ ] Share buttons?
    - [ ] Do they link to the correct page?
    - [ ] Do they have good share text/headlines in them?
- [ ] Is the piece deployed correctly?
    - [ ] The slug and host in **options.json** have been double-checked
    - [ ] /build/ has been deployed to S3
    - [ ] Is pym.js installed correctly in the post / CMS?
    - [ ] Is pym enabled properly in the app? (and called after load)
    - [ ] Is the post embed referencing Amazon S3 and *not GitHub*?
- [ ] Have the analytics been set up properly?
    - [ ] Is the GA UA code defined in **options.json**?
    - [ ] Is the GA code set up properly in **mustache/partials/header.mustache**?
    - [ ] Does the page emit **interactive-click** events on click?
    - [ ] Is there a function in the app to trigger **finished-interactive**?
    - [ ] Has Julia been given URL for heatmap click tracking?
- [ ] Has the data been locked down?
    - [ ] If reporter-driven, have they given final approval?
    - [ ] If running off Google sheets, has it been converted to local JSON/CSV?
- [ ] Is everybody who worked on it credited in some way?
- [ ] Does it work and look right at all screen sizes in the CMS?
    - [ ] Check at 650px (size of CMS desktop column)
    - [ ] Check at 320px (iPhone 3 portrait width)
    - [ ] Check at 1024px (basic desktop size)
    - [ ] What happens when you resize the window between 320 and 1024px?
- [ ] Has a share/poster image been created? (Large **screenshot.png** of the piece)

## Use
First `npm install` or perhaps `sudo npm install`

To run **/gulpfile.coffee** for development, from the root of the project use `npm start` or `gulp`

To deploy to gh-pages, run `gulp github`

To deploy to S3, run `gulp deploy`

The files in **/mustache/** are mustache templates/partials. The variables for those templates are defined in **/options.json**

The master style / CSS file is **/stylus/style.styl**, all other .styl files need to be included with **@import** in style.styl to be compiled into the final style.css file.


## What gulpfile.coffee does
+ **/mustache/** is compiled into **/build/index.html**
+ **/stylus/style.styl** is compiled into **build/style.css**
+ **/coffee/** is compiled into **/build/app.js**
+ **/javascript/** is compiled into **/build/lib.js**
+ Minifies CSS
+ Uglifies JS (vendor and compiled CoffeeScript)
+ Watches all files and compiles them on change
+ Starts a local webserver at ___localhost:8888___
+ Deploy /build/ to gh-pages with `gulp github`
+ --Deploy /build/ to S3--

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