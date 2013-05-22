class WebSocketClient
	handlers: []

	connect: (serverAddress, serverPort) ->
		@connection = io.connect(serverAddress + ":" + serverPort)
		@connection.on('message', @handleMessage)
		
	handleMessage: (message, callback) =>
		messageType = message.type
		handler.callback(message) for handler in @handlers when handler.messageType is messageType
		#console.log message
		#console.log message.type
		
	on: (messageType, callback) ->
		handler = 
			messageType : messageType
			callback 	: callback

		@handlers.push(handler)
		handler

	off: (handler) ->
		handlerIndex = @handlers.indexOf(handler)
		return if handlerIndex is -1
		@handlers.splice(handlerIndex, 1)

	send: (message) ->
		@connection.emit('message', { type: message })

exportForModule 'Arkanoid.Connection', WebSocketClient