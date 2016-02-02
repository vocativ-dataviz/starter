"use strict"
gulp = require("gulp")
merge = require("merge-stream")
plugins = require("gulp-load-plugins")({
  rename: {
    'gulp-awspublish': 's3',
    'gulp-gh-pages': 'github',
    'gulp-minify-css': 'mincss',
    'gulp-mustache-plus': 'mustache'
  }
})
nib = require("nib")
watch = plugins.watch

# options
options = require("./options")
options.prefixUrl = 'http://'+options.website.host
if options.website.port isnt ''
  options.prefixUrl += ':' + options.website.port

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
  'mv PROJECT_README.md README.md',
  'npm install',
  'bower install'
])

# Lint coffeescript for errors
gulp.task "lint", ->
  gulp.src("./src/coffee/*.coffee")
  .pipe plugins.coffeelint()
  .pipe plugins.coffeelint.reporter()

# Compile coffeescript
gulp.task "coffee", ["lint"], ->
  gulp.src("./src/coffee/*.coffee")
  .pipe plugins.sourcemaps.init()
  .pipe plugins.coffee(bare: true).on('error', plugins.util.log)  
  .pipe plugins.sourcemaps.write()
  .pipe plugins.if(->
    if options.project.development
      plugins.util.log 'Development mode'
      return false
    else
      plugins.util.log 'Production mode'
      return true
  , plugins.uglify())
  .pipe plugins.uglify()
  .pipe plugins.concat("app.js")  
  .pipe plugins.filesize()
  .pipe gulp.dest("./build/")

# Compile stylus to CSS
gulp.task "stylus", ->
  gulp.src("./src/styl/style.styl")
  .pipe plugins.stylus(use: [nib()])
  .pipe plugins.mincss(keepBreaks: true)
  .pipe plugins.filesize()
  .pipe gulp.dest("./build/")

# Compile mustache partials to HTML
gulp.task "mustache", ->
  gulp.src(["./src/tmpl/*.mustache"])
  .pipe(plugins.mustache(options, {},
    header: "./src/tmpl/partials/header.mustache"
    body: "./src/tmpl/partials/body.mustache"
    footer: "./src/tmpl/partials/footer.mustache"
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
  gulp.src([
    "./src/js/jquery/dist/jquery.js",
    "./src/js/lodash/dist/lodash.js",
    "./src/js/d3/d3.js",
    "./src/js/d3-tip/index.js",
    "./src/js/topojson/topojson.js",
    "./src/js/tabletop/src/tabletop.js",
    "./src/js/pym.js/dist/pym.js",
   ])
  .pipe plugins.concat("lib.js")
  .pipe plugins.uglify()  
  .pipe plugins.filesize()
  .pipe gulp.dest("./build/")

# Copy data files (CSV & JSON) from /data/ to /build/data/
gulp.task "data", ->
  gulp.src(["./src/data/*.csv", "./src/data/*.json"])
  .pipe plugins.filesize()
  .pipe gulp.dest("./build/data/")

# Copy images (.png and .svg) from /img/ to /build/img/
gulp.task "img", ->
  gulp.src(["./src/img/*.svg", "./src/img/*.png"])
  .pipe plugins.filesize()
  .pipe gulp.dest("./build/img/")

# Publish to gh-pages
gulp.task 'github', ->
  gulp.src('./build/**/*')
    .pipe plugins.github()

# Publish to S3
# Publish to S3
gulp.task 's3', ->
  publisher = plugins.s3.create {
    'accessKeyId': options.aws.key
    'secretAccessKey': options.aws.secret
    'params': {
      'Bucket': options.awss.bucket
    }
  }

  uploadHeaders =
    'Cache-Control': 'max-age=315360000, no-transform, public'

  uploadOptions =
    's3.path': 'vv/int/'

# you can use a filter to source only files you want gzipped
  gzipFilter = [
    'build/*.js'
    'public/*.html'
    'public/*.css'
  ]

# it's a good idea to create an inverse filter to avoid uploading duplicates
# see https://github.com/wearefractal/vinyl-fs#srcglobs-opt for more details
  plainFilter = [
    'build/*'
    '!build/*.js'
    '!build/*.html'
    '!build/*.css'
  ]

  gzip = gulp.src(gzipFilter).pipe(plugins.s3.gzip({ ext: '.gz' }))
  plain = gulp.src plainFilter

  # use the merge-stream plugin to merge the gzip and plain files and upload
  # them together
  merge(gzip, plain)
    .pipe publisher.cache()
    .pipe publisher.publish(uploadHeaders, uploadOptions) 
    # now when you sync files of the other type will not be deleted
    .pipe publisher.sync()
    .pipe publisher.cache()
    .pipe plugins.s3.reporter()

  gulp.src(['./build/**'])
  .pipe plugins.rename (path) ->
    path.dirname = '/vv/'+ options.project.slug + '/' + path.dirname + '/'
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
  watch "src/coffee/*.coffee", {name: 'Coffee'}, (events, done) ->
    gulp.start "coffee"

  watch "src/styl/*.styl", {name: 'Stylus'}, (events, done) ->
   gulp.start "stylus"

  watch [ "src/tmpl/*", "src/tmpl/partials/*" ], {name: 'Mustache'}, (events, done) ->
   gulp.start "mustache"

  watch "src/js/*", {name: 'Vendor JS'}, (events, done) ->
    gulp.start "js"

  watch "src/data/*", {name: 'Data'}, (events, done) ->
    gulp.start "data"

  watch "src/img/*", {name: 'Images'}, (events, done) ->
    gulp.start "img"


