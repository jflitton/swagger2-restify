gulp = require 'gulp'
coffee = require 'gulp-coffee'
coffeelint = require 'gulp-coffeelint'
mocha = require 'gulp-mocha'
istanbul = require 'gulp-istanbul'
del = require 'del'

sources =
  js: 'lib/**/*.js'
  coffee: 'src/**/*.coffee'
  tests: 'test/**/*.coffee'

gulp.task 'clean', (callback) ->
  del [sources.js], callback

gulp.task 'lint', ->
  return gulp.src sources.coffee
  .pipe coffeelint()
  .pipe coffeelint.reporter()
  .pipe coffeelint.reporter 'fail'

gulp.task 'compile', ->
  return gulp.src(sources.coffee)
  .pipe coffee({ bare: true })
  .pipe gulp.dest('lib/')

gulp.task 'watch', ['compile'], ->
  return gulp.watch sources.coffee, ['compile']

gulp.task 'test', ['compile'], ->
  return gulp.src sources.tests
  .pipe mocha()

gulp.task 'cover', ['compile'], ->
  return gulp.src sources.js
  .pipe istanbul()
  .pipe istanbul.hookRequire()
  .on 'finish', ->
    return gulp.src sources.tests
    .pipe mocha()
    .pipe istanbul.writeReports()

gulp.task 'build', ['clean', 'lint', 'cover']