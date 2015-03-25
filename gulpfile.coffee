gulp = require('gulp')
plugins = require('gulp-load-plugins')(
  rename: 'gulp-minify-css': 'min_css'
)

del = require 'del'
root_dir = './'
src_dir = "#{root_dir}/src"
dst_dir = "#{root_dir}/dst"

paths =
  # Add here the scripts you want to load when on dev
  scripts: [
    "#{dst_dir}/script/app.js"
  ]
  # The files from bower_components you want to inject on dev or concat on prod
  bower_components: []
  clean: [
    "#{dst_dir}"
  ]
  coffee: [
    "#{src_dir}/script/**/*.coffee"
  ]
  less: [
    "#{src_dir}/style/**/*.less"
  ]
  templates: [
    "#{root_dir}/index.html"
  ]


gulp.task 'clean', ->
  del paths.clean


gulp.task 'npm_install', ->
  plugins.shell.task(['npm install'])


gulp.task 'bower_install', ['npm_install'], ->
  plugins.bower()


gulp.task 'coffee', ->
  gulp.src(paths.coffee)
    .pipe plugins.plumber()
    .pipe plugins.coffee()
    .pipe gulp.dest("#{dst_dir}/script/")
    .pipe plugins.connect.reload()


gulp.task 'less', ->
  gulp.src("#{src_dir}/style/style.less")
    .pipe plugins.plumber()
    .pipe plugins.less()
    .pipe gulp.dest("#{dst_dir}/style/")
    .pipe plugins.connect.reload()


gulp.task 'inject', ['coffee'], ->
  gulp.src("#{root_dir}/index.html")
    .pipe plugins.plumber()
    .pipe plugins.inject(gulp.src(paths.bower_components, read: false), name: 'bower')
    .pipe plugins.inject(gulp.src(paths.scripts, read: false))
    .pipe gulp.dest("#{root_dir}")


gulp.task 'connect', ->
  plugins.connect.server(
    root: __dirname
    port: 8080
    livereload: true
  )


gulp.task 'watch', ['build'], ->
  gulp.watch paths.less, ['less']
  gulp.watch paths.coffee, ['coffee']
  gulp.watch paths.templates, ['less', 'coffee']
  gulp.watch "bower.json", ['bower_install']
  gulp.watch "package.json", ['npm_install']
  gulp.watch "gulpfile.coffee", ['build']


gulp.task 'default', [
  'npm_install'
  'bower_install'
  'build'
  'connect'
  'watch'
]

gulp.task 'build', [
  'coffee'
  'less'
  'inject'
]
