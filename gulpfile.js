// Include gulp
var gulp = require('gulp'); 

// Include gulp plugins
var coffeelint = require('gulp-coffeelint');
var stylus = require('gulp-stylus');
var coffee = require('gulp-coffee');
var concat = require('gulp-concat');
var uglify = require('gulp-uglify');
var rename = require('gulp-rename');
var webserver = require('gulp-webserver')
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
        .pipe(gulp.dest('./js/'))
})

// Compile Stylus
gulp.task('stylus', function(){
    gulp.src('./stylus/*.styl')
        .pipe(stylus({use: [nib()]}))
        .pipe(gulp.dest('./css/'))
})

// Watch Files For Changes
gulp.task('watch', function() {
    gulp.watch('coffee/*.coffee', ['lint', 'coffee']);
    gulp.watch('stylus/*.styl', ['stylus']);
});

gulp.task('webserver', function(){
    gulp.src('.')
        .pipe(webserver({
            host: 'localhost',
            port: '8888',
            fallback: 'index.html',
            livereload: true,
            directoryListing: false

        }))
})

// Default Task
gulp.task('default', ['lint', 'coffee', 'stylus', 'watch', 'webserver']);