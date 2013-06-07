root = require '../common/config'


class Mediator
	
	constructor: ->
		@androidConnector = new AndroidConnector(@)
		@htmlConnector = new HtmlConnector(@)

	
	forewardMessage: (message, sender) ->	
		if sender == "Android"
			#console.log message.type
			@htmlConnector.forewardMessage(message)
		else if sender == "Html"
			#console.log message.type
			@androidConnector.forewardMessage(message)
	
class AndroidConnector
	
	constructor: (med) ->

		mediator = med
		@io = require('socket.io').listen(root.Arkanoid.Config.androidPort)
		
		@io.sockets.on('connection', (socket) ->
			
			socket.on('message', (message) ->	
				mediator.forewardMessage(message, "Android")
			)
		)

	forewardMessage: (message) ->
		@io.sockets.emit('message', message)
		
class HtmlConnector

	constructor: (med) ->
		mediator = med

		@io = require('socket.io').listen(root.Arkanoid.Config.httpPort)
		
		@io.sockets.on('connection', (socket) ->
			
			socket.on('message', (message) ->
				mediator.forewardMessage(message, "Html")
			)
		)
		
	forewardMessage: (message) ->
		@io.sockets.emit('message', message)
	
mediator = new Mediator()
	
