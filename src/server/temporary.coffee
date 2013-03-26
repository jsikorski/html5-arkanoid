root = require '../common/config'

class Mediator
	
	constructor: ->
		console.log 'Mediator init'
		@androidConnector = new AndroidConnector(@)
		@htmlConnector = new HtmlConnector(@)
	
	forewardMessage: (message, sender) ->
		console.log 'Forewarding'
		if sender instanceof AndroidConnector
			@htmlConnector.forewardMessage(message)
		else if sender instanceof HtmlConnector
			@androidConnector.forewardMessage(message)
			
		
			
	
class AndroidConnector
	
	constructor: (med) ->
		mediator = med
		io = require('socket.io').listen(root.Arkanoid.Config.androidPort)

		console.log '[Android] Waiting for connection'
		
		io.sockets.on('connection', (socket) ->
			console.log '[Android] Connected'

			#open = require('open')
			#open('../game/game.html')
			
			#io.sockets.emit('message', {type : 'move:left'})
			#console.log '[Android] Message sent'
			
			socket.on('message', (message) ->
				console.log message
				console.log message.type		
				mediator.forewardMessage(message, @)
			)

			
		)

	forewardMessage: (message) ->
		console.log 'Sent to Android'
		io.sockets.emit('message', message)
		
		

class HtmlConnector

	constructor: (med) ->
		mediator = med

		io = require('socket.io').listen(root.Arkanoid.Config.httpPort)
		console.log '[HTML] Waiting for connection'

		io.sockets.on('connection', (socket) ->
			console.log 'Connected with HTTP application'

			socket.on('message', (message) ->
				mediator.forewardMessage(message, @)
			)
		)
		
	forewardMessage: (message) ->
		console.log 'Sent to HTML'
		io.sockets.emit('message', message)

		#io.sockets.emit('message', {type : 'move:left'})
	

mediator = new Mediator()
	
