root = require '../common/config'

class Mediator
	
	constructor: ->
		console.log 'Mediator init'
		@androidConnector = new AndroidConnector(@)
		@htmlConnector = new HtmlConnector(@)
	
	
	forewardMessage: (message, sender) ->
		console.log 'forewarding'
		if sender instanceof AndroidConnector
			console.log 'SEND TO HTML'
			@htmlConnector.forewardMessage(message)
			
		
			
	
class AndroidConnector
	
	constructor: (med) ->
		mediator = med
		io = require('socket.io').listen(root.Arkanoid.Config.androidPort)

		io.sockets.on('connection', (socket) ->
			console.log 'Connected with Android application'

			#open = require('open')
			#open('../game/game.html')

			socket.on('message', (message) 	->
				console.log "cokolwiek"
				console.log message	
				mediator.forewardMessage(message, @)

			)

			socket.on('anything', (message) 	->
				console.log "cokolwiek"
				console.log message	
				mediator.forewardMessage(message, @)

			)

			
		)
		
		
	
		
		
	

class HtmlConnector

	constructor: (med) ->
		mediator = med



		io = require('socket.io').listen(root.Arkanoid.Config.httpPort)
		

		io.sockets.on('connection', (socket) ->
			console.log 'Connected with HTTP application'
			
			
			
			#io.sockets.emit('message', {type : 'move:left'})
			#console.log 'message sent'
			
		)
		
	forewardMessage: (message) ->
		io.sockets.emit('message', message)


	#	socket.emit('message', {type : 'move:left'})
	

mediator = new Mediator()
	
