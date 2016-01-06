var path = require('path');
var gulp = require('gulp');
var clean = require('gulp-clean');
var gutil = require( 'gulp-util' );
var stylus = require('gulp-stylus');
var uglify = require('gulp-uglify');
var plumber = require( 'gulp-plumber' );
var browserSync = require('browser-sync');
var autoprefixer = require('gulp-autoprefixer');

gulp.task('browserSync', function() {
  browserSync({
    files: "./build/*",
    // server: {baseDir: "./build"},
    proxy: "0.0.0.0:3000"
  });
});

gulp.task('stylus', function () {
  gulp.src([
      './src/style/index.styl',
      './src/style/detail.styl',
      './src/style/list.styl',
    ])
    .pipe(plumber())
    .pipe(stylus({compress: true}))
    .pipe(autoprefixer())
    .pipe(gulp.dest('./build'));
});

gulp.task('script', function () {
  gulp.src('./src/script/*.js')
    .pipe(plumber())
    .pipe(uglify())
    .pipe(gulp.dest('./build'));
});

gulp.task('clean', function() {
  gulp.src('./build/*', {read: false})
    .pipe(clean());
})

gulp.task('watch', function() {
  gulp.watch('./src/**/*.styl', ['stylus']);
  gulp.watch('./src/**/*.js', ['script']);
});

gulp.task('default', ["script", "stylus", "watch", "browserSync"]);