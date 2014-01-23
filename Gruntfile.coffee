module.exports = (grunt) ->
  grunt.config.init
    pkg: grunt.file.readJSON('package.json')
    clean:
      lib:
        src: [ './lib/**' ]
    coffee:
      src:
        options:
          bare: true
          sourceMap: false
          join: false
        files: [
          {
            expand: true
            ext: '.js'
            cwd: './src'
            src: './**/*.coffee'
            dest: './lib'
          }
        ]
    browserify:
      dist:
        files:
          'static/bundle.js': ['lib/client.js']

  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-browserify'

  grunt.registerTask 'default',  ['clean:lib', 'coffee:src', 'browserify:dist']