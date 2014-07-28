module.exports = (grunt) ->
  grunt.initConfig {
    pkg: grunt.file.readJSON 'package.json'
    concat: {
      options: {
        separator: '/\n',
        footer: '/', # necessary for easy bulk importing as described in README
        banner: """
            /**\
             * Created by:\
             *   Per Guth <mail@perguth.de> (https://perguth.de/)\
             *   Johannes-C. J. Hilbert <mckollin.john@gmail.com>\
             *\
             * Licensed under AGPLv3\
             */
             -- 
             -- ## Installation
             -- 
             -- Open a `Command Window` or `SQL*Plus`. Copy and paste the complete contents of this file (`concat.pls`).
             -- 
             -- For first steps take a look into `test_functionality.sql`.

             
           """
      },
      dev: {
        src: ['**/*.pls'],
        dest: 'concat.pls'
      }
    }
  }
  grunt.loadNpmTasks 'grunt-contrib-concat'
  grunt.registerTask 'default', ['concat:dev']
