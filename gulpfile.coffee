"use strict"
gulp = require("gulp")
plugins = require("gulp-load-plugins")({
  rename: {
    'gulp-minify-css': 'mincss'
    'gulp-mustache-plus': 'mustache'
    'gulp-gh-pages': 'github'
    'gulp-awspublish': 's3'
  }
})
nib = require("nib")
watch = plugins.watch

# options
options = require("./options")
options.prefixUrl = 'http://'+options.website.host
if options.website.port isnt ''
  options.prefixUrl += ':'+options.website.port

# --- Tasks --- #
gulp.task "default", [
  "coffee"
  "stylus"
  "js"
  "mustache"
  "data"
  "img"
  "watch"
  "webserver"  
], -> gulp

gulp.task "mirror", [
  "github"
  "publish"
], -> gulp

# Remove previous git data and init fresh
gulp.task 'init', plugins.shell.task([
  'rm -rf .git',
  'git init',
  'rm README.md',
  'mv PROJECT_README.md README.md'
])

# Lint coffeescript for errors
gulp.task "lint", ->
  gulp.src("./source/coffee/*.coffee")
  .pipe plugins.coffeelint()
  .pipe plugins.coffeelint.reporter()

# Compile coffeescript
gulp.task "coffee", ["lint"], ->
  gulp.src("./source/coffee/*.coffee")
  #.pipe plugins.sourcemaps.init()
  .pipe plugins.coffee(bare: true).on('error', plugins.util.log)  
  #.pipe plugins.sourcemaps.write()
  .pipe plugins.if(->
    if options.project.development
      plugins.util.log 'Development mode'
      return false
    else
      plugins.util.log 'Production mode'
      return true
  , plugins.uglify())
  #.pipe plugins.uglify()
  .pipe plugins.concat("app.js")  
  .pipe plugins.filesize()
  .pipe gulp.dest("./build/")

# Compile stylus to CSS
gulp.task "stylus", ->
  gulp.src("./source/stylus/style.styl")
  .pipe plugins.stylus(use: [nib()])
  .pipe plugins.mincss(keepBreaks: true)
  .pipe plugins.filesize()
  .pipe gulp.dest("./build/")

# Compile mustache partials to HTML
gulp.task "mustache", ->
  gulp.src(["./source/mustache/*.mustache"])
  .pipe(plugins.mustache(options, {},
    header: "./source/mustache/partials/header.mustache"
    body: "./source/mustache/partials/body.mustache"
    footer: "./source/mustache/partials/footer.mustache"
  ))
  .pipe(plugins.rename(extname: ".html"))
  .pipe(plugins.htmlmin(
    collapseWhitespace: true
    collapseBooleanAttributes: true
    removeAttributeQuotes: true
    removeScriptTypeAttributes: true
    removeStyleLinkTypeAttributes: true
  ))
  .pipe gulp.dest("./build/")

# Concat and uglify vendor JS files
gulp.task "js", ->
  gulp.src("./source/javascript/*.js")
  .pipe plugins.concat("lib.js")
  .pipe plugins.uglify()  
  .pipe plugins.filesize()
  .pipe gulp.dest("./build/")

# Prefix link,script,img tags in HTML with full URL
###
gulp.task "prefix", ->
  gulp.src("./build/*.html")
  .pipe plugins.prefix(options.prefixUrl, null, true)
  .pipe gulp.dest('./build/')
###

# Copy data files (CSV & JSON) from /data/ to /build/data/
gulp.task "data", ->
  gulp.src(["./source/data/*.csv", "./source/data/*.json"])
  .pipe plugins.filesize()
  .pipe gulp.dest("./build/data/")

# Copy images (.png and .svg) from /img/ to /build/img/
gulp.task "img", ->
  gulp.src(["./source/img/*.svg", "./source/img/*.png"])
  .pipe plugins.filesize()
  .pipe gulp.dest("./build/img/")

# Publish to gh-pages
gulp.task 'github', ->
  gulp.src('./build/**/*')
    .pipe plugins.github()

# Publish to S3
gulp.task 's3', ->
  publisher = plugins.s3.create {
    key: options.aws.key
    secret: options.aws.secret
    bucket: options.aws.bucket
  }

  headers = {
    'Cache-Control': 'max-age=315360000, no-transform, public'
  }

  gulp.src(['./build/**'])
  .pipe plugins.rename (path) ->
    path.dirname = '/'+options.project.slug+'/'+path.dirname+'/'
    return path
  #.pipe plugins.s3.gzip({ ext: '.gz' })
  .pipe publisher.publish()
  .pipe publisher.sync()
  .pipe publisher.cache()
  .pipe plugins.s3.reporter({
    states: ['create', 'update', 'delete']
  })

# Start a local webserver for development
gulp.task "webserver", ->
  gulp.src("./build/")
  .pipe plugins.webserver(
    host: options.website.host
    port: options.website.port
    fallback: "build/index.html"
    livereload: true
    directoryListing: false
    open: true
  )

# Watch files for changes and livereload when detected
gulp.task "watch", ->
  watch "source/coffee/*.coffee", {name: 'Coffee'}, (events, done) ->
    gulp.start "coffee"
    done()

  watch "source/stylus/*.styl", {name: 'Stylus'}, (events, done) ->
   gulp.start "stylus"
   done()

  watch [ "source/mustache/*", "source/mustache/partials/*" ], {name: 'Mustache'}, (events, done) ->
   gulp.start "mustache"
   done()

  watch "source/javascript/*", {name: 'Vendor JS'}, (events, done) ->
    gulp.start "js"
    done()

  watch "source/data/*", {name: 'Data'}, (events, done) ->
    gulp.start "data"
    done()

  watch "source/img/*", {name: 'Images'}, (events, done) ->
    gulp.start "img"
    done()


