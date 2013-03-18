class ControlHandler
	activeMoves: {}

	isLeftActive: ->
		@activeMoves['left']?

	isRightActive: ->
		@activeMoves['right']?

	isStartActive: ->
		@activeMoves['start']?

	reset: (stateName)->
		delete @activeMoves['stateName']


class KeyboardHandler extends ControlHandler
	keyboardMapping:
		37: 'left'
		39: 'right'
		32: 'start'

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
		webSocketClient.on("move:left", => 
			@activeMoves['left'] = true
		)
		
		webSocketClient.on("move:right", => 
			@activeMoves['right'] = true
		)

		webSocketClient.on("start", => 
			@activeMoves['start'] = true
		)
		
		webSocketClient.on("move:reset", =>  
			@reset('left')
			@reset('right')
		)


class Facade
	controlHandlers: []

	constructor: (webSocketClient) ->
		@controlHandlers.push(
			new KeyboardHandler(),
			new ServerHandler(webSocketClient)
		)

	isLeftActive: ->
		_.some(@controlHandlers, (handler) -> handler.isLeftActive())

	isRightActive: ->
		_.some(@controlHandlers, (handler) -> handler.isRightActive())

	isStartActive: ->
		_.some(@controlHandlers, (handler) -> handler.isStartActive())

	resetForAll: (stateName)->
		handler.reset(stateName) for handler in @controlHandlers

exportForModule 'Arkanoid.Control', Facade