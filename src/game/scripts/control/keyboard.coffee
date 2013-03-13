module 'Arkanoid.Control'

class KeyboardMapping
	@left: 37
	@right: 39

class KeyboardController
	keysDown: {}

	constructor: ->
		addEventListener('keydown', (e) =>
			@keysDown[e.keyCode] = true
		, false)

		addEventListener('keyup', (e) =>
			delete @keysDown[e.keyCode]
		, false)

	isLeftButtonPressed: ->
		@keysDown[KeyboardMapping.left]?

	ifRightButtonPressed: ->
		@keysDown[KeyboardMapping.right]?

class Arkanoid.Control.Facade
	constructor: ->
		@keyboardController = new KeyboardController()

	isLeftActive: ->
		@keyboardController.isLeftButtonPressed()

	isRightActive: ->
		@keyboardController.ifRightButtonPressed()