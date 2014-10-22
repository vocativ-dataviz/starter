'use strict';

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
};

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
var github = require('gulp-gh-pages');
var s3 = require('gulp-s3');
var gutil = require('gulp-util');
var gulpif = require('gulp-if');
var gzip = require('gulp-gzip');

// Lint CoffeeScript
gulp.task('lint', function() {
    return gulp
        .src('./coffee/*.coffee')
        .pipe(coffeelint())
        .pipe(coffeelint.reporter());
});

// Compile CoffeeScript
gulp.task('coffee', function() {
    return gulp
        .src('./coffee/*.coffee')
        .pipe(coffee({bare: true}))
        .pipe(uglify())
        .pipe(filesize())
        .pipe(gulp.dest('./build/'));
});

// Compile Stylus
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

// Compile mustache to HTML
gulp.task('mustache', function() {
    return gulp
        .src(['./html/header.html', './html/body.html', './html/footer.html'])
        .pipe(concat('all.mustache'))
        .pipe(mustache(options))
        .pipe(concat('index.html'))
        .pipe(gulp.dest('./build/'));
});

// Concat vendor files
gulp.task('vendor', function() {
    return gulp
        .src('./vendor/*.js')
        .pipe(concat('vendor.js'))
        .pipe(uglify())
        .pipe(filesize())
        .pipe(gulp.dest('./build/'));
});

// Move data to build
gulp.task('data', function() {
    return gulp
        .src('./data/*.csv', './data/*.json')
        .pipe(filesize())
        .pipe(gulp.dest('./build/data/'));
});

// Watch Files For Changes
gulp.task('watch', function() {
    gulp.watch('coffee/*.coffee', ['lint', 'coffee']);
    gulp.watch('stylus/*.styl', ['stylus']);
    gulp.watch('html/*', ['mustache']);
    gulp.watch('vendor/*', ['vendor']);
});

// Deploy to gh-pages with `gulp github`
gulp.task('github', function() {
    return gulp
        .src('./build/')
        .pipe(github());
});

// Run local webserver at localhost:8888
gulp.task('webserver', function() {
    return gulp
        .src('./build/')
        .pipe(webserver({
            host: options.host,
            port: options.port,
            fallback: 'build/index.html',
            livereload: true,
            directoryListing: false
        }));
});

gulp.task('gzip', ['build'], function() {
    return gulp
        .src('build/**/*.{js,css}')
        .pipe(gzip())
        .pipe(rename(function(path) {
            path.extname = '';
        }))
        .pipe(gulp.dest('./build/'));
});

// Deploy to S3 in the CloudFront context
gulp.task('deploy', ['gzip'], function() {
    gulp.src(['./build/**', '!./build/**/*.{js,css,gz}'], {read: false})
        .pipe(s3(options.aws, {
            uploadPath: '/interactives/' + projectName + '/',
            headers: {
                'Cache-Control': 'max-age=300, no-transform, public'
            }
        }));
    gulp.src('./build/**/*.{js,css,gz}', {read: false})
        .pipe(s3(options.aws, {
            uploadPath: '/interactives/' + projectName + '/',
            headers: {
                'Cache-Control': 'max-age=300, no-transform, public',
                'Content-Encoding': 'gzip'
            }
        }));
});

// Default Task
gulp.task('default', ['lint', 'coffee', 'stylus', 'vendor', 'watch', 'mustache', 'data', 'deploy', 'webserver']);