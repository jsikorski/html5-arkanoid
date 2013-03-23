class Board
	@width: 498
	@height: 750

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

		elements = [
			new Arkanoid.Graphics.Element(background, 'img/background.png')
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
		
		@collisionsDetector = new Arkanoid.Models.CollisionsDetector()
		@collisionsDetector.addPair(ball, pad)
		@collisionsDetector.addMany(ball, edges)

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

		@collisionsDetector.check()
		@modelsUpdater.update(delta/1000, @control)

		@renderer.render()
		@then = now

		requestAnimationFrame(@mainLoop)

	looseLife: ->

exportForModule 'Arkanoid', Game