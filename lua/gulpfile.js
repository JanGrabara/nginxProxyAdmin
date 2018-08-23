const gulp = require('gulp')
const path = require('path')

gulp.task('default', function () {
    gulp.src(path.join(__dirname, '/node_modules/monaco-editor/min/vs/loader.js'))
        .pipe(gulpCopy(path.join(__dirname, '/static/monaco-loader.js')))
})
