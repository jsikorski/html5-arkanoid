class Board
	@width: window.innerWidth * 0.95
	@height: window.innerHeight * 0.95

class Game
	init: ->
		pad = new Arkanoid.Models.Pad()
		ball = new Arkanoid.Models.Ball()
		level = new Arkanoid.Models.Level()
		client = new Arkanoid.Connection.WebSocketClient()

		@initGraphics(pad, ball, level)
		@initModels(pad, ball, level)

		@initConnection(client)
		@initControl(client)

		@startMainLoop()

	initGraphics: (pad, ball, level) ->
		canvasContext = @createCanvasContext()
		background = new Arkanoid.Models.Model()
		background.width = Board.width
		background.height = Board.height

		elements = [
			new Arkanoid.Graphics.Element(background, 'img/background.jpg')
			new Arkanoid.Graphics.Element(pad, 'img/pad.png'),
			new Arkanoid.Graphics.Element(ball, 'img/ball.png')
		]
		elements.push(new Arkanoid.Graphics.Element(target, 'img/target3.png')) for target in level.getTargets()

		@renderer = new Arkanoid.Graphics.Renderer(canvasContext, elements)

	createCanvasContext: ->
		canvas = document.createElement('canvas')
		canvas.width = Board.width
		canvas.height = Board.height
		document.body.appendChild(canvas)
		
		canvas.getContext('2d')

	initModels: (pad, ball, level) ->
		edges = Arkanoid.Models.EdgesBuilder.buildFor(Board.width, Board.height)
		
		pad.addCollidingModels(edges)
		ball.addCollidingModels(pad)
		ball.addCollidingModels(edges)

		ball.addCollidingModels(level.getTargets())

		offsetX = pad.width / 2 - ball.width / 2
		offsetY = -ball.height
		ball.bindPositionWith(pad, offsetX,  offsetY)

		@modelsUpdater = new Arkanoid.Models.Updater([pad, ball])

	initConnection: (client) ->
		client.connect(Arkanoid.Config.serverAddress, Arkanoid.Config.httpPort)

	initControl: (client) ->
		@control = new Arkanoid.Control.Facade(client)

	startMainLoop: ->
		@then = Date.now()
		@mainLoop()

	mainLoop: =>
		now = Date.now()
		delta = now - @then

		@modelsUpdater.update(delta/1000, @control)

		@renderer.render()
		@then = now

		requestAnimationFrame(@mainLoop)

	looseLife: ->

exportForModule 'Arkanoid', Board, Game