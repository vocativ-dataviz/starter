// Include gulp
var gulp = require('gulp'); 

// Include Our Plugins
//var jshint = require('gulp-jshint');
//var sass = require('gulp-sass');
//var concat = require('gulp-concat');
//var uglify = require('gulp-uglify');
//var rename = require('gulp-rename');

var coffeelint = require('gulp-coffeelint');
var stylus = require('gulp-stylus');
var coffee = require('gulp-coffee');
var concat = require('gulp-concat');
var uglify = require('gulp-uglify');
var rename = require('gulp-rename');
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
        .pipe(coffee({bare: true}).on('error', gutil.log))
        .pipe(gulp.dest('./js/'))
})

// Compile Stylus
gulp.task('stylus', function(){
    gulp.src('./stylus/*.styl')
        .pipe(stylus({use: [nib()]}))
        .pipe(gulp.dest('./css/'))
})

// Concatenate & Minify JS
gulp.task('scripts', function() {
    return gulp.src('js/*.js')
        .pipe(concat('all.js'))
        .pipe(gulp.dest('dist'))
        .pipe(rename('all.min.js'))
        .pipe(uglify())
        .pipe(gulp.dest('dist'));
});

// Watch Files For Changes
gulp.task('watch', function() {
    gulp.watch('js/*.js', ['lint', 'scripts']);
    gulp.watch('scss/*.scss', ['sass']);
});

// Default Task
gulp.task('default', ['lint', 'coffee', 'stylus', 'scripts', 'watch']);