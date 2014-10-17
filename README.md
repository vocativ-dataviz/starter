# Vocativ Dataviz Template/Starter

A lightweight starting point to create interactive visualizations of data. Of all sorts. (Maps, charts, graphs, tools)

## Use
First `npm install`

To run **/gulpfile.js**, from the root of the project use `npm start` or `gulp`

The files in **/html/** can contain mustache templates. The variables for those templates are defined in the **/gulpfile.js** file.

#### What gulpfile.js does
+ **/html/** is compiled into **/index.html**
+ **/stylus/** is compiled into **/css/**
+ **/coffee/** is compiled into **/js/**
+ **/vendor/** is compiled into **/js/vendor.js**
+ Watches all files and compiles them on change
+ Starts a local webserver at ___localhost:8888___

## Gulp Packages
[Found in Package.json](https://github.com/Vocativ/dataviz-starter/blob/master/package.json)

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
+ Report events to Google Analytics, including clicks on the page, as well as a 'completion' event to be fired when all sections are viewed, or interactive is otherwise 'completed'
+ ~~Have visualization respond to breakpoints (ie show less data on mobile, or use smaller padding/margin sizes)~~
+ ~~Include Vocativ house styles such as colors, buttons, and fonts~~
+ ~~Pull in data from google sheets, if the reporter's data is there~~
+ ~~Have PYM.js set up (and the structure required for that) so that the piece is easily embeddable in WordPress as a resizable iframe~~


## To-do
+ Add [gulp-uncss](https://www.npmjs.org/package/gulp-uncss)
+ Add [gulp-gh-pages](https://github.com/rowoot/gulp-gh-pages)
+ Add [gulp-s3](https://www.npmjs.org/package/gulp-s3) and write similar deploy task to [Matt's script](https://github.com/Vocativ/wp-interactive/blob/master/selfies/gulpfile.js#L159)
```
gulp.task('deploy', ['gzip'], function() {


    // gutil.log('Deploying to ' + stage);

    var aws;
    try {
        aws = {
              'key': process.env.AWS_KEY,
              'secret': process.env.AWS_SECRET,
              'bucket': 'interactives'
        };

        if(!aws.key || !aws.secret) {
            new Error('Must have both AWS_KEY and AWS_SECRET env variables set');
        }
    } catch(err) {
        gutil.log('Could not parse aws keys from keys.json. Aborting deployment.'.red);
        return;
    }

    gulp.src(['./public/**', '!./public/**/*.{js,css,gz}'], { read: false })
        .pipe(s3(aws, {
            uploadPath: '/interactives/' + projectName + '/',
            headers: {
                'Cache-Control': 'max-age=300, no-transform, public'
            }
        }));
    gulp.src('./public/**/*.{js,css,gz}', { read: false })
        .pipe(s3(aws, {
            uploadPath: '/interactives/' + projectName + '/',
            headers: {
                'Cache-Control': 'max-age=300, no-transform, public',
                'Content-Encoding': 'gzip'
            }
        }));

});
```
+ Add Google [Analytics JS / tracking code](https://developers.google.com/analytics/devguides/collection/analyticsjs/)
+ Add GA custom [interaction events](https://developers.google.com/analytics/devguides/collection/analyticsjs/events)
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