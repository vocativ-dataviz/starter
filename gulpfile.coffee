"use strict"
gulp = require("gulp")

# plugins
coffeelint    = require("gulp-coffeelint")
stylus        = require("gulp-stylus")
coffee        = require("gulp-coffee")
concat        = require("gulp-concat")
uglify        = require("gulp-uglify")
rename        = require("gulp-rename")
webserver     = require("gulp-webserver")
mincss        = require("gulp-minify-css")
util          = require("gulp-util")
filesize      = require("gulp-filesize")
mustache      = require("gulp-mustache-plus")
nib           = require("nib")
github        = require("gulp-gh-pages")
s3            = require("gulp-s3")
gulpif        = require("gulp-if")
gzip          = require("gulp-gzip")
htmlmin       = require("gulp-htmlmin")
watch         = require("gulp-watch")
shell         = require("gulp-shell")

# options
options = require("./options")

# tasks
gulp.task "lint", ->
  gulp.src("./coffee/*.coffee")
  .pipe coffeelint()
  .pipe coffeelint.reporter()

gulp.task "coffee", ["lint"], ->
  gulp.src("./coffee/*.coffee")
  .pipe coffee(bare: true)
  .pipe uglify()
  .pipe filesize()
  .pipe gulp.dest("./build/")

gulp.task "stylus", ->
  gulp.src("./stylus/style.styl")
  .pipe stylus(use: [nib()])
  .pipe mincss(keepBreaks: true)
  .pipe filesize()
  .pipe gulp.dest("./build/")

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
  .pipe concat("lib.js")
  .pipe uglify()
  .pipe filesize()
  .pipe gulp.dest("./build/")

gulp.task "data", ->
  gulp.src("./data/*.csv", "./data/*.json")
  .pipe filesize()
  .pipe gulp.dest("./build/data/")

gulp.task "watch", ->
  watch "coffee/*.coffee", {name: 'Coffee'}, (events, done) ->
    gulp.start "coffee"
    done()

  watch "stylus/*.styl", {name: 'Stylus'}, (events, done) ->
   gulp.start "stylus"
   done()

  watch [ "mustache/*", "mustache/partials/*" ], {name: 'Mustache'}, (events, done) ->
   gulp.start "mustache"
   done()

  watch "javascript/*", {name: 'Vendor JS'}, (events, done) ->
    gulp.start "js"
    done()

gulp.task 'git-reset', shell.task([
  'rm -rf .git',
  'git init'
])

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

gulp.task "deploy", ["deploy"]