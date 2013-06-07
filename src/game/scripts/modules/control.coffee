class ControlHandler
	activeMoves: {}

	isLeftActive: ->
		@activeMoves['left']?

	isRightActive: ->
		@activeMoves['right']?

	isStartActive: ->
		@activeMoves['start']?

	isShootActive:->
		@activeMoves['shoot']?
		
	reset: (stateName)->
		delete @activeMoves[stateName]


class KeyboardHandler extends ControlHandler
	keyboardMapping:
		37: 'left'
		39: 'right'
		13: 'start'
		32: 'shoot'

	constructor: ->
		addEventListener('keydown', (e) => 
			@pressKey(e.keyCode)
		, false)

		addEventListener('keyup', (e) =>
			@unpressKey(e.keyCode)
		, false)

	pressKey: (keyCode) ->
		keyMap = @keyboardMapping[keyCode]
		@activeMoves[keyMap] = true if keyMap?

	unpressKey: (keyCode) ->
		keyMap = @keyboardMapping[keyCode]
		delete @activeMoves[keyMap] if keyMap?


class ServerHandler extends ControlHandler
	constructor: (webSocketClient) ->
		@webSocketClient = webSocketClient

		webSocketClient.on("move:left", => 
			@reset('right')
			@activeMoves['left'] = true
		)
		
		webSocketClient.on("move:right", => 
			@reset('left')
			@activeMoves['right'] = true
		)

		webSocketClient.on("start", => 
			@activeMoves['start'] = true
		)
		
		webSocketClient.on("move:reset", =>  
			@reset('left')
			@reset('right')
		)
		
		webSocketClient.on("shoot", =>  
			@activeMoves['shoot'] = true
		)
		
		webSocketClient.on("restart", =>
			location.reload()
		)

	sendMessage: (message) ->
		@webSocketClient.send(message)


class Facade
	controlHandlers: []

	constructor: (webSocketClient) ->
		@controlHandlers.push(
			new KeyboardHandler(),
			new ServerHandler(webSocketClient)
		)
		@serverHandler = new ServerHandler(webSocketClient)

	isLeftActive: ->
		_.some(@controlHandlers, (handler) -> handler.isLeftActive())

	isRightActive: ->
		_.some(@controlHandlers, (handler) -> handler.isRightActive())

	isStartActive: ->
		_.some(@controlHandlers, (handler) -> handler.isStartActive())

	isShootActive: ->
		_.some(@controlHandlers, (handler) -> handler.isShootActive())	
		
	reset: (stateName)->
		handler.reset(stateName) for handler in @controlHandlers
	
	sendMessage: (message) ->
		@serverHandler.sendMessage(message)

exportForModule 'Arkanoid.Control', Facade