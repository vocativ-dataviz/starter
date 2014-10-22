'use strict';

var gulp = require('gulp');

// plugins
var coffeelint = require('gulp-coffeelint');
var stylus = require('gulp-stylus');
var coffee = require('gulp-coffee');
var concat = require('gulp-concat');
var uglify = require('gulp-uglify');
var rename = require('gulp-rename');
var webserver = require('gulp-webserver');
var mincss = require('gulp-minify-css');
var util = require('gulp-util');
var filesize = require('gulp-filesize');
var mustache = require('gulp-mustache-plus');
var nib = require('nib');
var github = require('gulp-gh-pages');
var s3 = require('gulp-s3');
var gulpif = require('gulp-if');
var gzip = require('gulp-gzip');
var htmlmin = require('gulp-htmlmin');

// options
var options = require('./options');

gulp.task('lint', function() {
    return gulp
        .src('./coffee/*.coffee')
        .pipe(coffeelint())
        .pipe(coffeelint.reporter());
});

gulp.task('coffee', ['lint'], function() {
    return gulp
        .src('./coffee/*.coffee')
        .pipe(coffee({bare: true}))
        .pipe(uglify())
        .pipe(filesize())
        .pipe(gulp.dest('./build/'));
});

gulp.task('stylus', function() {
    return gulp
        .src('./stylus/style.styl')
        .pipe(stylus({use: [nib()]}))
        /*.pipe(gulp.dest('./css/')) Un-comment to see un-minified CSS */
        .pipe(mincss({keepBreaks: true}))
        .pipe(filesize())
        /*.pipe(concat('style.min.css')) Un-comment to combine CSS without Stylus require()*/
        //.pipe(gulp.dest('./css/'))
        .pipe(gulp.dest('./build/'));
});

gulp.task('mustache', function() {
    return gulp
        .src(['./mustache/*.mustache'])
        .pipe(mustache(options, {}, {
          'header': './mustache/partials/header.mustache',
          'body': './mustache/partials/body.mustache',
          'footer': './mustache/partials/footer.mustache'
        }))
        .pipe(rename({
            extname: '.html'
        }))
        .pipe(htmlmin({
            collapseWhitespace: true,
            collapseBooleanAttributes: true,
            removeAttributeQuotes: true,
            removeScriptTypeAttributes: true,
            removeStyleLinkTypeAttributes: true,
            minifyJS: true,
            minifyCSS: true
        }))
        .pipe(gulp.dest('./build/'));
});

gulp.task('js', function() {
    return gulp
        .src('./javascript/*.js')
        .pipe(concat('lib.js'))
        .pipe(uglify())
        .pipe(filesize())
        .pipe(gulp.dest('./build/'));
});

gulp.task('data', function() {
    return gulp
        .src('./data/*.csv', './data/*.json')
        .pipe(filesize())
        .pipe(gulp.dest('./build/data/'));
});

gulp.task('watch', function() {
    gulp.watch('coffee/*.coffee', ['lint', 'coffee']);
    gulp.watch('stylus/*.styl', ['stylus']);
    gulp.watch('mustache/*', ['mustache']);
    gulp.watch('javascript/*', ['js']);
});

gulp.task('webserver', function() {
    return gulp
        .src('./build/')
        .pipe(webserver({
            host: options.website.host,
            port: options.website.port,
            fallback: 'build/index.html',
            livereload: true,
            directoryListing: false
        }));
});

gulp.task('default', ['coffee', 'stylus', 'js', 'mustache', 'data', 'webserver', 'watch'], function() {
    return gulp;
});

gulp.task('gzip', ['build'], function() {
    return gulp
        .src('build/**/*.{html,js,css}')
        .pipe(gzip())
        .pipe(rename({
            extname: ''
        }))
        .pipe(gulp.dest('./build/'));
});

gulp.task('deploy', ['gzip'], function() {
    gulp.src(['./build/**', '!./build/**/*.{html,js,css}'], {read: false})
        .pipe(s3(options.aws, {
            uploadPath: options.aws.path + '/' + options.project.slug + '/',
            headers: {
                'Cache-Control': 'max-age=' + options.aws.maxAge + ', no-transform, public'
            }
        }));
    gulp.src('./build/**/*.{html,js,css}', {read: false})
        .pipe(s3(options.aws, {
            uploadPath: options.aws.path + '/' + options.project.slug + '/',
            headers: {
                'Cache-Control': 'max-age=' + options.aws.maxAge + ', no-transform, public',
                'Content-Encoding': 'gzip'
            }
        }));
});

gulp.task('deploy', ['deploy']);