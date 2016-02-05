"use strict"
gulp = require("gulp")
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

gulp.task "staging", [
  "github"
], -> gulp

gulp.task "production", [
  "s3"
], ->

# Remove previous git data and init fresh
gulp.task 'init', plugins.shell.task([
  'rm -rf .git',
  'git init',
  'rm README.md',
  'mv options.sample.js options.js'
  'mv PROJECT_README.md README.md',
  'npm install',
  'gulp bower',
  'gulp namespace'
])

gulp.task "namespace", ->
  stylNamespace = 'section#vv-' + options.project.slug + '\n'
  jsNamespace = 'parentEl = \'section#vv-' + options.project.slug + '\'\n'
  console.log('parent viz element:', stylNamespace)
  gulp.src('./src/coffee/app.coffee')
    .pipe plugins.insert.prepend(jsNamespace)
    .pipe gulp.dest('./src/coffee')
  gulp.src('./src/styl/style.styl')
    .pipe plugins.insert.append(stylNamespace)
    .pipe gulp.dest('./src/styl')

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

# Bower installs entire repos of js dependencies.
# Grab only what you need
gulp.task 'bower', plugins.shell.task([
    'bower install',
    'bower-installer'
  ])

# Concat and uglify vendor JS files
gulp.task "js", ->
  gulp.src 'src/js/lib/**/*.js'
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
      'Bucket': 'interactives-dev'
    }
  }

  uploadHeaders =
    'Cache-Control': 'max-age=315360000, no-transform, public'

  uploadOptions =
    's3.path': 'vv/'

  gulp.src(['./build/**'])
    .pipe plugins.rename (path) ->
      path.dirname = 'vv/' + options.project.slug + '/' + path['dirname'] + '/'
      return path
    .pipe publisher.publish(uploadHeaders, uploadOptions)
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


