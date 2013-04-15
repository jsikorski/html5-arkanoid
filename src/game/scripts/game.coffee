class Board
	@width: window.innerWidth * 0.95
	@height: window.innerHeight * 0.95

class Game

	init: ->
		@pad = new Arkanoid.Models.Pad()
		@livesCounter = new Arkanoid.Models.LivesCounter(3)
		@ball = new Arkanoid.Models.Ball()
		@level = new Arkanoid.Models.Level()
		client = new Arkanoid.Connection.WebSocketClient()

		@initGraphics(@pad, @livesCounter, @ball, @level)
		@initModels(@pad, @livesCounter, @ball, @level)

		@initConnection(client)
		@initControl(client)

		@startMainLoop()

	initGraphics: (pad, livesCounter, ball, level) ->
		canvasContext = @createCanvasContext()
		background = new Arkanoid.Models.Model()
		background.width = Board.width
		background.height = Board.height

		elements = [
			new Arkanoid.Graphics.Element(background, 'img/background.jpg')
			new Arkanoid.Graphics.Element(pad, 'img/pad.png'),
			new Arkanoid.Graphics.Element(ball, 'img/ball.png')
		]
		elements.push(new Arkanoid.Graphics.Element(life, 'img/life.png')) for life in livesCounter.getLives()
		elements.push(new Arkanoid.Graphics.Element(target, 'img/target3.png')) for target in level.getTargets()

		@renderer = new Arkanoid.Graphics.Renderer(canvasContext, elements)

	createCanvasContext: ->
		canvas = document.createElement('canvas')
		canvas.width = Board.width
		canvas.height = Board.height
		document.body.appendChild(canvas)
		
		canvas.getContext('2d')

	initModels: (pad, livesCounter, ball, level) ->
		edges = Arkanoid.Models.EdgesBuilder.buildFor(Board.width, Board.height)
		
		pad.addCollidingModels(edges)
		ball.addCollidingModels(pad)
		ball.addCollidingModels(edges)
		ball.setGameHandler(@)

		ball.addCollidingModels(level.getTargets())
		target.addCollidingModels(ball) for target in level.getTargets()

		offsetX = pad.width / 2 - ball.width / 2
		offsetY = -ball.height
		ball.bindPositionWith(pad, offsetX,  offsetY)

		models = [pad, ball].concat(level.getTargets())
		@modelsUpdater = new Arkanoid.Models.Updater(models)

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
		@renderer.remove(@livesCounter.popLife())

		if (!@livesCounter.isEmpty())

			@ball.reset()

			offsetX = @pad.width / 2 - @ball.width / 2
			offsetY = -@ball.height
			@ball.bindPositionWith(@pad, offsetX,  offsetY)


exportForModule 'Arkanoid', Board, Game