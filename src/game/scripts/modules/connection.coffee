class WebSocketClient
	handlers: []

	connect: (serverAddress) ->
		@connection = io.connect(serverAddress)
		@connection.on('message', @handleMessage)

	handleMessage: (message, callback) =>
		messageType = message.type
		handler.callback(message) for handler in @handlers when handler.messageType is messageType

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


exportForModule 'Arkanoid.Connection', WebSocketClient