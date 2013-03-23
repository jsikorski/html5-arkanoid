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
		canvas.width = 498
		canvas.height = 750
		document.body.appendChild(canvas)
		
		canvas.getContext('2d')

	initModels: (pad, ball) ->
		@modelsUpdater = new Arkanoid.Models.Updater([pad, ball])

	initConnection: (client) ->
		client.connect(Arkanoid.Config.serverAddress, Arkanoid.Config.httpPort)

	initControl: (client) ->
		@control = new Arkanoid.Control.Facade(client)

	startMainLoop: ->
		@then = Date.now()
		setInterval(@mainLoop, 1)

	mainLoop: =>
		now = Date.now()
		delta = now - @then

		@modelsUpdater.update(delta/1000, @control)

		@renderer.render()
		@then = now

	looseLife: ->

exportForModule 'Arkanoid', Game