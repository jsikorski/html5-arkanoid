module 'Arkanoid'

class Arkanoid.Game
	constructor: ->
		@pad = new Arkanoid.Models.Pad()
		@ball = new Arkanoid.Models.Ball()
		@control = new Arkanoid.Control.Facade()
		@renderer = new Arkanoid.Graphics.Renderer()

	init: ->
		@createCanvasContext()
		@initGraphics()
		@startMainLoop()

	createCanvasContext: ->
		canvas = document.createElement('canvas')
		@canvasContext = canvas.getContext('2d')

		canvas.width = 498
		canvas.height = 750
		document.body.appendChild(canvas)

	initGraphics: ->
		background = new Arkanoid.Models.Background()
		@renderer.addElements(
			new Arkanoid.Graphics.Element(background, 'img/background.png')
			new Arkanoid.Graphics.Element(@pad, 'img/pad.png'),
			new Arkanoid.Graphics.Element(@ball, 'img/ball.png')
		)

	startMainLoop: ->
		@then = Date.now()
		setInterval(@mainLoop, 1)

	mainLoop: =>
		now = Date.now()
		delta = now - @then

		@updatePadPosition(delta / 1000)
		@renderer.render(@canvasContext)

		@then = now

	updatePadPosition: (modifier) ->
		delta = 255 * modifier
		@pad.moveLeft(delta) if @control.isLeftActive()
		@pad.moveRight(delta) if @control.isRightActive()


Arkanoid.init = ->
	game = new Arkanoid.Game()
	game.init()