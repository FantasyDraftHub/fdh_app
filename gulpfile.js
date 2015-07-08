var gulp = require('gulp');
var coffee = require('gulp-coffee');
var sass = require('gulp-sass');
var concat = require('gulp-concat');
var replace = require('gulp-replace');
var server = require('gulp-server-livereload');
var watch = require('gulp-watch');
var shell = require('gulp-shell');
var inject = require('gulp-inject');

var yargs = require('yargs').argv;
var vendor = require('./config/vendor-dependencies');
var rmdir = require('rimraf');

/*
  DEPS
 */
var ENVS = require('./config/environment');
var env = ENVS['dev'];
var buildDir = "./build-dev";

/*
  BUILD TASKS
 */

// Environment
gulp.task('app:environment', function(done) {
  if(yargs.env !== undefined && ENVS[yargs.env] !== undefined) {
    env = ENVS[yargs.env];
    buildDir = "./build-" + yargs.env;
  }
  done();
});

gulp.task('app:reset', ['app:environment'], function() {
  rmdir.sync(buildDir);
});

// Dev Server
gulp.task('dev:server', function() {
  gulp.src(buildDir)
    .pipe(server({
      livereload: true,
      directoryListing: {
        enable: false,
        path: buildDir
      },
      path: 'build'
    }));
});

gulp.task('app:start-server', ['app:dependencies'], function() {
  gulp.start('dev:server');
  watch(['./app/js/**/*.coffee', '!./app/js/constants/app-constants.coffee'], function() {
    gulp.start('app:coffee');
  });
  watch('./app/styles/**/*.scss', function() {
    gulp.start('app:sass');
  });
  watch('./app/views/**/*.html', function() {
    gulp.start('app:templates');
  });
  watch('./app/images/*', function() {
    gulp.start('app:images');
  });
  gulp.watch('./app/js/constants/app-constants.coffee', ['app:config']);
  gulp.watch('./app/index.html', ['app:index']);
});

// Coffeescript
gulp.task('app:coffee', function(done) {
  gulp.src(['./app/js/**/*.coffee', '!./app/js/constants/app-constants.coffee'])
    .pipe(coffee({bare: true}))
    .pipe(gulp.dest(buildDir + '/js')).on('end', done);
});

gulp.task('app:config', function(done) {
  gulp.src('./app/js/constants/app-constants.coffee')
    .pipe(coffee({bare: true}).on('error', function(err) {console.error(err)}))
    .pipe(replace('<% envApiUrl %>', env.apiUrl))
    .pipe(replace('<% envEnv %>', env.env))
    .pipe(replace('<% envPusherKey %>', env.pusherKey))
    .pipe(gulp.dest(buildDir + '/js/constants')).on('end', done);
});

// SASS
gulp.task('app:sass', function(done) {
  gulp.src('./app/styles/**/*.scss')
    .pipe(sass())
    .pipe(gulp.dest(buildDir + '/css')).on('end', done);
});

// HTML & STATIC ASSETS
gulp.task('app:index', function(done) {

  var sources = gulp.src([
    buildDir + '/js/**/*.js',
    '!' + buildDir + '/js/vendor.js',
    '!' + buildDir + '/js/app.js',
    '!' + buildDir + '/js/constants/app-constants.js'
  ], {read: false});


  var removeJsBuildPrefix = function(filepath) {
    return '<script src="' + filepath.replace(buildDir.replace('.', ''), '') + '"></script>';
  };

  var removeCssBuildPrefix = function(filepath) {
    return '<link rel="stylesheet" href="' + filepath.replace(buildDir.replace('.', ''), '') + '">';
  };

  gulp.src('./app/index.html')
    .pipe(inject(sources, {transform: removeJsBuildPrefix}))
    .pipe(gulp.dest(buildDir)).on('end', done);
});

gulp.task('app:templates', function(done) {
  gulp.src('./app/views/**/*.html')
    .pipe(gulp.dest(buildDir + '/views')).on('end', done);
});

gulp.task('app:images', function(done) {
  gulp.src('./app/images/*')
    .pipe(gulp.dest(buildDir + '/images')).on('end', done);
});

// VENDOR
gulp.task('app:vendor:js', function(done) {
  gulp.src(vendor.vendorJs)
    .pipe(concat('vendor.js'))
    .pipe(gulp.dest(buildDir + '/js')).on('end', done);
});

gulp.task('app:vendor:css', function(done) {
  gulp.src(vendor.vendorCss)
    .pipe(concat('vendor.css'))
    .pipe(gulp.dest(buildDir + '/css')).on('end', done);
});

gulp.task('app:vendor:fonts', function(done) {
  gulp.src(vendor.vendorFonts)
    .pipe(gulp.dest(buildDir + '/fonts')).on('end', done);
});

gulp.task('app:vendor', ['app:vendor:js', 'app:vendor:css', 'app:vendor:fonts']);

/*
  HELPERS
 */
gulp.task('app:dependencies', [
  'app:coffee',
  'app:config',
  'app:sass',
  'app:templates',
  'app:images',
  'app:vendor'
], function(){
  gulp.start('app:index');
});

gulp.task('app:build', ['app:dependencies']);

/*
  PUBLIC TASKS
 */
gulp.task('serve', ['app:reset'], function() {
  gulp.start('app:start-server');
});

gulp.task('build', ['app:reset'], function() {
  gulp.start('app:build');
  // TODO: When ready for production add production stuff
});

gulp.task('default', ['serve']);


