"use strict"
gulp = require("gulp")

# plugins
coffeelint = require("gulp-coffeelint")
stylus = require("gulp-stylus")
coffee = require("gulp-coffee")
concat = require("gulp-concat")
uglify = require("gulp-uglify")
rename = require("gulp-rename")
webserver = require("gulp-webserver")
mincss = require("gulp-minify-css")
util = require("gulp-util")
filesize = require("gulp-filesize")
mustache = require("gulp-mustache-plus")
nib = require("nib")
github = require("gulp-gh-pages")
s3 = require("gulp-s3")
gulpif = require("gulp-if")
gzip = require("gulp-gzip")
htmlmin = require("gulp-htmlmin")
watch = require("gulp-watch")

# options
options = require("./options")
gulp.task "lint", ->
  gulp.src("./coffee/*.coffee")
  .pipe coffeelint()
  .pipe coffeelint.reporter()

gulp.task "coffee", ["lint"], ->
  gulp.src("./coffee/*.coffee")
  .pipe(coffee(bare: true))
  .pipe(uglify())
  .pipe(filesize())
  .pipe gulp.dest("./build/")

gulp.task "stylus", ->
  gulp.src("./stylus/style.styl")
  .pipe stylus(use: [nib()])
  .pipe mincss(keepBreaks: true)
  .pipe filesize()
  .pipe gulp.dest("./build/")
  #.pipe(gulp.dest('./css/')) Un-comment to see un-minified CSS

  #.pipe(concat('style.min.css')) Un-comment to combine CSS without Stylus require()

  #.pipe(gulp.dest('./css/'))
gulp.task "mustache", ->
  gulp.src(["./mustache/*.mustache"]).pipe(mustache(options, {},
    header: "./mustache/partials/header.mustache"
    body: "./mustache/partials/body.mustache"
    footer: "./mustache/partials/footer.mustache"
  ))
  .pipe(rename(extname: ".html")).pipe(htmlmin(
    collapseWhitespace: true
    collapseBooleanAttributes: true
    removeAttributeQuotes: true
    removeScriptTypeAttributes: true
    removeStyleLinkTypeAttributes: true
    minifyJS: true
    minifyCSS: true
  ))
  .pipe gulp.dest("./build/")

gulp.task "js", ->
  gulp.src("./javascript/*.js")
  .pipe(concat("lib.js"))
  .pipe(uglify())
  .pipe(filesize())
  .pipe gulp.dest("./build/")

gulp.task "data", ->
  gulp.src("./data/*.csv", "./data/*.json")
  .pipe(filesize())
  .pipe gulp.dest("./build/data/")

gulp.task "watch", ->
  watch "coffee/*.coffee", (files, cb) ->
    gulp.start [
      "lint"
      "coffee"
    ], cb
    return

  watch "stylus/*.styl", (files, cb) ->
    gulp.start "stylus", cb
    return

  watch [
    "mustache/*"
    "mustache/partials/*"
  ], (files, cb) ->
    gulp.start "mustache", cb
    return

  watch "javascript/*", (files, cb) ->
    gulp.start "js", cb
    return

  return

gulp.task "webserver", ->
  gulp.src("./build/").pipe webserver(
    host: options.website.host
    port: options.website.port
    fallback: "build/index.html"
    livereload: true
    directoryListing: false
  )

gulp.task "default", [
  "coffee"
  "stylus"
  "js"
  "mustache"
  "data"
  "webserver"
  "watch"
], -> gulp

gulp.task "gzip", ["build"], ->
  gulp.src("build/**/*.{html,js,css}")
  .pipe(gzip())
  .pipe(rename(extname: ""))
  .pipe gulp.dest("./build/")

gulp.task "deploy", ["gzip"], ->
  gulp.src([
    "./build/**"
    "!./build/**/*.{html,js,css}"
  ],
    read: false
  )
  .pipe s3(options.aws,
    uploadPath: options.aws.path + "/" + options.project.slug + "/"
    headers:
      "Cache-Control": "max-age=" + options.aws.maxAge + ", no-transform, public"
  )
  gulp.src("./build/**/*.{html,js,css}",
    read: false
  )
  .pipe s3(options.aws,
    uploadPath: options.aws.path + "/" + options.project.slug + "/"
    headers:
      "Cache-Control": "max-age=" + options.aws.maxAge + ", no-transform, public"
      "Content-Encoding": "gzip"
  )
  return

gulp.task "deploy", ["deploy"]