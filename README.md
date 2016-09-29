# Vocativ Dataviz Template/Starter

A lightweight starting point to create interactive visualizations of data. Of all sorts (besides maps, which has it's own starter). (Charts, graphs, apps, tools)

## Prerequisites
On OS X 10.9, aka Mavericks, be sure to have the following libraries installed:

+ [Homebrew](http://brew.sh/): OS X package manager
+ [Node.js](https://nodejs.org/): JavaScript framework
+ [Gulp.js](http://gulpjs.com/): streaming build system
+ [Stylus](https://learnboost.github.io/styl/): CSS preprocessor

Copy and paste the following code into your terminal if you're starting on a fresh machine that does not have any of those prerequisites.

```
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew install node
```

## Getting Started
+ Clone starter `git clone https://github.com/vocativ-dataviz/starter.git NEW-PROJECT`
+ Go to it `cd NEW-PROJECT`
+ `subl options.sample.js` and **edit the project name and slug for your project**
+ Install the core node libraries like gulp.js `npm run deps`
+ Then, install dependencies from package.json & bower.json and remove the starter's git history `gulp init`
+ Create new repo in GitHub web app
+ Add repo in GitHub desktop app, add GitHub URL as remote
+ `gulp`
+ Sometimes things don't work properly the first time around, if this happens, just `gulp` again
+ **Develop**
+ Want to show internally? `gulp staging` and see it at <http://vocativ-dataviz.github.io/NEW-PROJECT/>
+ Ready to deploy? `gulp production` and see it at <http://interactives-dev.s3.amazonaws.com/vv/NEW-PROJECT/>

## Application structure
This starter is a jumping-off-point for all sorts of different interactive dataviz. It tries to take care of all the things you don't want to think of so you can move quickly, but leaving enough room for anything to be possible.

#### /styl/style.styl
The master style / CSS file is **/styl/style.styl**, all other .styl files need to be included with **@import** in style.styl to be compiled into the final style.css file.

#### /tmpl/partials/body.mustache
This is the only HTML file you need to be modifying, in most cases.

#### /app/app.js
This is the main file for the app, where initial variables are defined, data is loaded and cleaned, and the proper chart function to visualize the data is called. 

# So you wanna deploy an interactive?
Follow this basic checklist!

- [ ] Has all of the copy been double-checked by Editorial?
- [ ] Is there a link to the data?
    - [ ] The original source?
    - [ ] A cleaned Google Spreadsheet? (Make sure it can't be edited)
- [ ] Is the piece deployed correctly?
    - [ ] The slug and host in **options.js** have been double-checked
    - [ ] /build/ has been deployed to S3
    - [ ] Is pym.js installed correctly in the post / CMS?
    - [ ] Is pym enabled properly in the app? (and called after load)
    - [ ] Is the post embed referencing Amazon S3 and *not GitHub*?
- [ ] Have the analytics & testing been set up properly?
    - [ ] Is the GA UA code defined in **options.js**?
    - [ ] Is the GA code set up properly in **tmpl/partials/header.mustache**?
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

To run **/gulpfile.js** for development, from the root of the project use `npm start` or `gulp`

To deploy to gh-pages, run `gulp github`

To deploy to S3, run `gulp publish`

The files in **/tmpl/** are mustache templates/partials. The variables for those templates are defined in **/options.js**


## What gulpfile.js does
+ `gulp init`: removes **.git** and moves **PROJECT_README.md** to **README.md** to initialize a new project
+ **/tmpl/** is compiled into **/build/index.html**
+ **/styl/style.styl** is compiled into **build/style.css**
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
+ [Stylus](http://learnboost.github.io/styl/)
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