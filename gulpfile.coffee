gulp = require 'gulp'
mocha = require 'gulp-mocha'
istanbul = require 'gulp-coffee-istanbul'

sourceFiles = ['coolClass.coffee']
specFiles = ['test/*.coffee']

gulp.task 'coverage', ->
    gulp.src sourceFiles
    .pipe istanbul
        includeUntested: false
    .pipe istanbul.hookRequire()
    .on 'finish', ->
        gulp.src specFiles
        .pipe mocha reporter: 'spec'
        .pipe istanbul.writeReports
            dir: '.'
            reporters: ['text-summary', 'cobertura']

gulp.task 'default', ['coverage']
