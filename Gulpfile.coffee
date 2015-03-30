fs = require 'fs'
gulp = require 'gulp'
gulp.tasklist = require 'gulp-task-listing'
gulp.util = require 'gulp-util'
coffee = require 'gulp-coffee'
coffeelint = require 'gulp-coffeelint'
minifyHTML = require 'gulp-minify-html'
clean = require 'gulp-clean'
concat = require 'gulp-concat'
cssmin = require 'gulp-cssmin'
browserify = require 'gulp-browserify'
rename = require 'gulp-rename'
newer = require 'gulp-newer'

sources =
	home : "public/"
	coffee : 'public/src/*.coffee'
	mycss : 'public/css/*.css'
	images : 'public/img/*.*'

destinations =
	js : 'www/js'
	home : 'www'
	css : 'www/css'
	img : "www/img"

gulp.task 'help', gulp.tasklist

gulp.task 'clean', ->
	gulp.src ['www','build'], read:false
		.pipe clean force:true


gulp.task 'js', ->
	gulp.src 'public/src/*.coffee', read:false
		.pipe browserify
			transform : ['coffeeify']
			extensions : ['.coffee']
		.pipe rename extname:'.js'
		.pipe gulp.dest destinations.js


gulp.task 'bower.fonts', ->
	gulp.src [
		"bower_components/bootstrap/fonts/glyphicons-halflings-regular.eot"
		"bower_components/bootstrap/fonts/glyphicons-halflings-regular.svg"
		"bower_components/bootstrap/fonts/glyphicons-halflings-regular.ttf"
		"bower_components/bootstrap/fonts/glyphicons-halflings-regular.woff"
		], base:'bower_components/bootstrap/fonts/'
		.pipe gulp.dest 'www/fonts'

gulp.task 'bower.css', ->
	gulp.src [
		"bower_components/bootstrap/dist/css/bootstrap.min.css" ], base:'bower_components/'
		.pipe newer 'www/css/style.css'
		.pipe concat 'style.css'
		.pipe gulp.dest destinations.css
		.on 'error', gulp.util.log


gulp.task 'mycss', ->
	gulp.src sources.mycss
		.pipe gulp.dest destinations.css
		.on 'error', gulp.util.log

gulp.task 'css', ['mycss','bower.css','bower.fonts']

gulp.task 'etc', ->
	gulp.src [
		"bower_components/angular-resource/angular-resource.min.js.map"
	], base : "bower_components/angular-resource/"
		.pipe gulp.dest destinations.js

gulp.task 'bower.js', ->
	gulp.src [
		"bower_components/jquery/dist/jquery.min.js"
		"bower_components/bootstrap/dist/js/bootstrap.min.js"
		# "bower_components/moment/min/moment-with-langs.min.js"
		"bower_components/angular/angular.min.js"
		# "bower_components/angular-animate/angular-animate.min.js"
		# "bower_components/angular-route/angular-route.min.js"
		# "bower_components/angular-moment/angular-moment.js"
		"bower_components/angular-resource/angular-resource.min.js"
		"bower_components/async/lib/async.js"
		"bower_components/lodash/lodash.min.js"
	], base:'bower_components/'
		.pipe newer 'www/js/bower.js'
		.pipe concat 'bower.js'
		.pipe gulp.dest destinations.js
		.on 'error', gulp.util.log

gulp.task 'images', ->
	gulp.src sources.images
		.pipe gulp.dest destinations.img
		.on 'error', gulp.util.log

gulp.task 'assets', ['css','js','bower.js','etc','images'], ->
	gulp.src ['www/**','!www/*']
		.pipe gulp.dest 'build'

gulp.task 'build', ['assets'], ->
	gulp.src sources.home
		.pipe minifyHTML()
		.pipe gulp.dest destinations.home
		.on 'error', gulp.util.log

gulp.task 'lint', ->
	gulp.src sources.coffee
		.pipe coffeelint()
		.pipe coffeelint.reporter()

gulp.task 'watch', ->
	gulp.watch [sources.coffee,sources.home,sources.mycss], ->
		setTimeout gulp.start.bind(gulp,['build']), 500

gulp.task 'default', ['clean'], ->
	gulp.start ['build','watch']