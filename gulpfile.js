var options = {
    'org': 'Vocativ',
    'host': 'localhost',
    'port': 8888,
    'projName': 'Project Name',
    'gaCode': 'UA-XXXX-Y'
}

// Include gulp
var gulp = require('gulp'); 

// Include gulp plugins
var coffeelint = require('gulp-coffeelint');
var stylus = require('gulp-stylus');
var coffee = require('gulp-coffee');
var concat = require('gulp-concat');
var uglify = require('gulp-uglify');
var rename = require('gulp-rename');
var webserver = require('gulp-webserver');
var mincss = require('gulp-minify-css');
var gutil = require('gulp-util');
var filesize = require('gulp-filesize');
var mustache = require('gulp-mustache');
var nib = require('nib');

// Lint Coffeescript
gulp.task('lint', function() {
    gulp.src('./coffee/*.coffee')
        .pipe(coffeelint())
        .pipe(coffeelint.reporter())
})

// Compile Coffeescript
gulp.task('coffee', function(){
    gulp.src('./coffee/*.coffee')
        .pipe(coffee({bare: true}))
        .pipe(uglify())
        .pipe(filesize())
        .pipe(gulp.dest('./js/'))
})

// Compile Stylus
gulp.task('stylus', function(){
    gulp.src('./stylus/*.styl')
        .pipe(stylus({use: [nib()]}))
        /*.pipe(gulp.dest('./css/')) Un-comment to see un-minified CSS */
        .pipe(mincss({keepBreaks: true}))        
        .pipe(filesize())
        /*.pipe(concat('style.min.css')) Un-comment to combine CSS without Stylus require()*/
        .pipe(gulp.dest('./css/'))
})

// Compile mustache to HTML
gulp.task('mustache', function(){
    gulp.src(['./html/header.html', './html/body.html', './html/footer.html'])
    .pipe(concat('all.mustache'))
    .pipe(mustache(options))
    .pipe(concat('index.html'))
    .pipe(gulp.dest('.'))
})

// Concat vendor files
gulp.task('vendor', function(){
    gulp.src('./vendor/*.js')
    .pipe(concat('vendor.js'))
    .pipe(uglify())
    .pipe(filesize())
    .pipe(gulp.dest('./js/'))
})

// Watch Files For Changes
gulp.task('watch', function() {
    gulp.watch('coffee/*.coffee', ['lint', 'coffee']);
    gulp.watch('stylus/*.styl', ['stylus']);
    gulp.watch('html/*', ['mustache'])
    gulp.watch('vendor/*', ['vendor'])
});

// Run local webserver at localhost:8888
gulp.task('webserver', function(){
    gulp.src('.')
        .pipe(webserver({
            host: options.host,
            port: options.port,
            fallback: 'index.html',
            livereload: true,
            directoryListing: false

        }))
})

// Default Task
gulp.task('default', ['lint', 'coffee', 'stylus', 'vendor', 'watch', 'mustache', 'webserver']);