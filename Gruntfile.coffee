module.exports = (grunt) ->
	grunt.initConfig
		config: grunt.file.readJSON('config.json')
		
		clean: ['<%= config.build_dir %>', '<%= config.release_dir %>']

		coffee:
			glob_to_multiple:
				expand: true
				cwd: '<%= config.src_dir %>'
				src: '**/*.coffee'
				dest: '<%= config.build_dir %>'
				ext: '.js'

		copy:
			build:
				files: [
					expand: true, cwd: '<%= config.src_dir %>', src: ['**/*.png', '**/*.html'], dest: '<%= config.build_dir %>/'
				]
			release: 
				files: [
					expand: true, cwd: '<%= config.build_dir %>', src: ['**/*.png', '**/*.html'], dest: '<%= config.release_dir %>/'
				]
			
		concat:
			game:
				src: ['<%= config.build_dir %>/game/**/exports.js', '<%= config.build_dir %>/game/**/*.js']
				dest: '<%= config.release_dir %>/game/game.js'
			server:
				src: ['<%= config.build_dir %>/server/**/*.js']
				dest: '<%= config.release_dir %>/server/server.js'

	grunt.loadNpmTasks('grunt-contrib-clean')
	grunt.loadNpmTasks('grunt-contrib-coffee')
	grunt.loadNpmTasks('grunt-contrib-copy')
	grunt.loadNpmTasks('grunt-contrib-concat')

	grunt.registerTask('default', ['clean', 'coffee', 'copy:build', 'concat', 'copy:release'])