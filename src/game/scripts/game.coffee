class Game
	constructor: ->
		@pad = new Arkanoid.Models.Pad()
		@ball = new Arkanoid.Models.Ball()

	init: ->
		@initGraphics()
		@initConnection()
		@initControl()
		@initPhysics()
		@startMainLoop()

	initGraphics: ->
		canvasContext = @createCanvasContext()
		background = new Arkanoid.Models.Model()

		@renderer = new Arkanoid.Graphics.Renderer(canvasContext)
		@renderer.addElements(
			new Arkanoid.Graphics.Element(background, 'img/background.png')
			new Arkanoid.Graphics.Element(@pad, 'img/pad.png'),
			new Arkanoid.Graphics.Element(@ball, 'img/ball.png')
		)

	createCanvasContext: ->
		canvas = document.createElement('canvas')
		canvas.width = 498
		canvas.height = 750
		document.body.appendChild(canvas)
		
		canvas.getContext('2d')

	initConnection: ->
		@client = new Arkanoid.Connection.WebSocketClient()
		@client.connect(Arkanoid.Config.serverAddress)

	initControl: ->
		@control = new Arkanoid.Control.Facade(@client)

	initPhysics: ->
		@physicsUpdater = new Arkanoid.Physics.Updater()
		@physicsUpdater.addModels(@ball,@pad)

	startMainLoop: ->
		@then = Date.now()
		setInterval(@mainLoop, 1)

	mainLoop: =>
		now = Date.now()
		delta = now - @then

		@physicsUpdater.update(delta/1000, @control)

		@renderer.render()
		@then = now

	looseLife: ->

exportForModule 'Arkanoid', Game