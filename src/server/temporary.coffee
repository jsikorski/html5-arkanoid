root = require '../common/config'

class Mediator
	
	constructor: ->
		console.log 'Mediator init'
		@androidConnector = new AndroidConnector(@)
		@htmlConnector = new HtmlConnector(@)
	
	notifyAndroidConnector: ->
		console.log 'Notification sent'
		androidConnector.notify
	
	forewardMessage: (message, sender) ->
		console.log 'forewarding'
		#if sender instanceof AndroidConnector
		console.log 'SEND TO HTML'
		@htmlConnector.forewardMessage(message)
			
		
			
	
class AndroidConnector
	
	constructor: (med) ->
		mediator = med
		io = require('socket.io').listen(root.Arkanoid.Config.androidPort)
		console.log '[Android] Waiting for connection'
		
		io.sockets.on('connection', (socket) ->
			console.log '[Android] Connected'
			
			#io.sockets.emit('message', {type : 'move:left'})
			#console.log '[Android] Message sent'
			
			socket.on('message', (message) ->
				console.log message		
				mediator.forewardMessage(message, @)
			)
		)
		
	

class HtmlConnector

	constructor: (med) ->
		mediator = med
		@io = require('socket.io').listen(root.Arkanoid.Config.httpPort)
		console.log '[HTML] Waiting for connection'

		@io.sockets.on('connection', (socket) ->
			console.log '[HTML] Connected'
			mediator.notifyAndroidConnector
			
			
			#io.sockets.emit('message', {type : 'move:left'})
			#console.log 'message sent'
		)	
		
		
	forewardMessage: (message) ->
		console.log 'Sent'
		@io.sockets.emit('message', message)


		#io.sockets.emit('message', {type : 'move:left'})
	

mediator = new Mediator()
	
