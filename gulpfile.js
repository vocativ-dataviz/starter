"use strict";

/**
 * Module dependencies.
 */
const gulp = require("gulp");
const moment = require('moment');
const nib = require("nib");

// gulp plugins
const plugins = require("gulp-load-plugins")({
  rename: {
    'gulp-awspublish': 's3',
    'gulp-gh-pages': 'github',
    'gulp-minify-css': 'mincss',
    'gulp-mustache-plus': 'mustache'
  }
});

const watch = plugins.watch;

/**
 * Options
 */
const options = require("./options");
options.prefixUrl = 'http://' + options.website.host;

if (options.website.port !== '') {
  options.prefixUrl += ':' + options.website.port;
}

/**
 * Tasks
 */
gulp.task("default", [
  "app",
  "engine",
  "data",
  "fonts",
  "img",
  "js",
  "mustache",
  "stylus",
  "watch",
  "webserver"
], function() {
  return gulp;
});

gulp.task("staging", [
  "github",
  "commit:staging"
], function() {
  return gulp;
});

gulp.task("production", [
  "github",
  "s3",
  "commit:production"
]);

gulp.task('init',
  plugins.shell.task([
    'rm -rf .git',
    'git init',
    'rm README.md',
    'mv PROJECT_README.md README.md',
    'npm install',
    'gulp bower',
    'gulp namespace'
  ])
);

gulp.task("namespace", function() {
  const stylNamespace = 'div#vv-' + options.project.slug + '\n';
  const jsNamespace = 'parentEl = \'div#vv-' + options.project.slug + '\'\n';
  console.log('parent viz element:', stylNamespace);
  return gulp.src('./src/styl/style.styl')
    .pipe(plugins.insert.append(stylNamespace))
    .pipe(gulp.dest('./src/styl'));
});

// handle app.js
gulp.task("app", function() {
  return gulp.src(["./src/app/*.js"])
    .pipe(plugins.concat('app.js'))
    .pipe(plugins.uglify())
    .pipe(gulp.dest("./build/"));
});

// handle engine.js
gulp.task("engine", function() {
  return gulp.src(["./src/engine/*.js"])
    .pipe(plugins.uglify())
    .pipe(gulp.dest("./build/"));
});

// compile stylus to CSS
gulp.task("stylus", function() {
  return gulp.src("./src/styl/style.styl")
    .pipe(plugins.stylus({
      use: [nib()]
    }))
    .pipe(plugins.mincss({
      keepBreaks: true
    }))
    .pipe(plugins.filesize())
    .pipe(gulp.dest("./build/"));
});

// compile mustache partials to HTML
gulp.task("mustache", function() {
  return gulp.src(["./src/tmpl/*.mustache"])
    .pipe(plugins.mustache(options, {}, {
      header: "./src/tmpl/partials/header.mustache",
      body: "./src/tmpl/partials/body.mustache",
      footer: "./src/tmpl/partials/footer.mustache",
      mailchimp: "./src/tmpl/partials/mailchimp.mustache"
    }))
    .pipe(plugins.rename({
      extname: ".html"
    }))
    .pipe(plugins.htmlmin({
      collapseWhitespace: true,
      collapseBooleanAttributes: true,
      removeAttributeQuotes: true,
      removeScriptTypeAttributes: true,
      removeStyleLinkTypeAttributes: true
    }))
    .pipe(gulp.dest("./build/"));
});

// bower installs entire repos of js dependencies.
// grab only what you need
gulp.task('bower', plugins.shell.task([
  'bower install',
  'bower-installer'
]));

// concat and uglify vendor JS files
gulp.task("js", ["bower"], function() {
  return gulp.src('src/js/lib/**/*.js')
    .pipe(plugins.concat("lib.js"))
    .pipe(plugins.uglify())
    .pipe(plugins.filesize())
    .pipe(gulp.dest("./build/"));
});

// copy data files (CSV & JSON) from /data/ to /build/data/
gulp.task("data", function() {
  return gulp.src([
    "./src/data/*.csv",
    "./src/data/*.json"
  ])
    .pipe(plugins.filesize())
    .pipe(gulp.dest("./build/data/"));
});

// copy images (.png and .svg) from /img/ to /build/img/
gulp.task("img", function() {
  return gulp.src([
    "./src/img/*.svg",
    "./src/img/*.png",
    "./src/img/*.gif",
    "./src/img/*.mp4",
    "./src/img/*.webm"
 ])
    .pipe(plugins.filesize())
    .pipe(gulp.dest("./build/img/"));
});

// copy images (.png and .svg) from /fonts/ to /build/fonts/
gulp.task("fonts", function() {
  return gulp.src(["./src/fonts/*"])
    .pipe(plugins.filesize())
    .pipe(gulp.dest("./build/fonts/"));
});

// publish to gh-pages
gulp.task('github', function() {
  return gulp.src('./build/**/*')
    .pipe(plugins.github());
});

// create commit message for staging
gulp.task('commit:staging', function() {
  const stagingCommit = `git commit -am "redeploying to staging ${options.project.stagingUrl} ${moment().format()}"`;
  plugins.shell.task([
    'git add -A .',
    stagingCommit,
    'git push origin master'
  ]);
});

// create commit message for production
gulp.task('commit:production', function() {
  const productionCommit = `git commit -am "redeploying to production ${options.project.productionUrl} ${moment().format()}"`;
  plugins.shell.task([
    'git add -A .',
    productionCommit,
    'git push origin master'
  ]);
});

// publish to S3
gulp.task('s3', function() {
  const publisher = plugins.s3.create({
    'accessKeyId': options.aws.key,
    'secretAccessKey': options.aws.secret,
    'params': {
      'Bucket': options.aws.bucket
    }
  });
  const uploadHeaders = {
    'Cache-Control': 'max-age=0, no-transform, public'
  };
  const uploadOptions = {
    's3.path': options.aws.path
  };
  return gulp.src(['./build/**'])
    .pipe(plugins.rename(function(path) {
      path.dirname = uploadOptions['s3.path'] + options.project.slug + '/' + path.dirname + '/';
      return path;
    }))
    .pipe(publisher.publish(uploadHeaders, uploadOptions))
    .pipe(publisher.cache())
    .pipe(plugins.s3.reporter());
});

// start a local webserver for development
gulp.task("webserver", function() {
  return gulp.src("./build/")
    .pipe(plugins.webserver({
      host: options.website.host,
      port: options.website.port,
      fallback: "build/index.html",
      livereload: true,
      directoryListing: false,
      open: true
    }));
});

/**
 * Watch Task
 * Watch files for changes and livereload when detected 
 */
gulp.task("watch", function() {
  watch("src/styl/*.styl", {
    name: 'Stylus'
  }, function(events, done) {
    return gulp.start("stylus");
  });

  watch(["src/tmpl/*", "src/tmpl/partials/*"], {
    name: 'Mustache'
  }, function(events, done) {
    return gulp.start("mustache");
  });

  watch("src/js/*", {
    name: 'Vendor JS'
  }, function(events, done) {
    return gulp.start("js");
  });

  watch("src/app/*.js", {
    name: 'Main JS'
  }, function(events, done) {
    return gulp.start("app");
  });

  watch("src/engine/*.js", {
    name: 'Main JS'
  }, function(events, done) {
    return gulp.start("engine");
  });

  watch("src/data/*", {
    name: 'Data'
  }, function(events, done) {
    return gulp.start("data");
  });

  return watch("src/img/*", {
    name: 'Images'
  }, function(events, done) {
    return gulp.start("img");
  });
});