class Board
	@width: 500 #window.innerWidth
	@height: 750 #window.innerHeight

class Game
	init: ->
		pad = new Arkanoid.Models.Pad()
		ball = new Arkanoid.Models.Ball()
		client = new Arkanoid.Connection.WebSocketClient()

		@initGraphics(pad, ball)
		@initModels(pad, ball)
		@initConnection(client)
		@initControl(client)
		@startMainLoop()

	initGraphics: (pad, ball) ->
		canvasContext = @createCanvasContext()
		background = new Arkanoid.Models.Model()
		background.width = Board.width
		background.height = Board.height

		elements = [
			new Arkanoid.Graphics.Element(background, 'img/background.jpg')
			new Arkanoid.Graphics.Element(pad, 'img/pad.png'),
			new Arkanoid.Graphics.Element(ball, 'img/ball.png')
		]

		@renderer = new Arkanoid.Graphics.Renderer(canvasContext, elements)

	createCanvasContext: ->
		canvas = document.createElement('canvas')
		canvas.width = Board.width
		canvas.height = Board.height
		document.body.appendChild(canvas)
		
		canvas.getContext('2d')

	initModels: (pad, ball) ->
		edges = Arkanoid.Models.EdgesBuilder.buildFor(Board.width, Board.height)
		
		pad.addCollidingModels(edges)
		ball.addCollidingModels(pad)
		ball.addCollidingModels(edges)

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

exportForModule 'Arkanoid', Game