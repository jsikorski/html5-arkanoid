# the graphic
bg = 
	ready: false
	img: null

pad =
	x: 250
	y: 700
	ready: false
	img: null

ball =
	x: 200
	y: 200
	ready: false
	img: null

# keyboard data
keysDown = {}

addEventListener('keydown', (e) ->
	keysDown[e.keyCode] = true
, false)

addEventListener('keyup', (e) ->
	delete keysDown[e.keyCode]
, false)

# game functions
createCanvas = ->
	window.canvas = document.createElement('canvas')
	window.canvasContext = canvas.getContext('2d')

	canvas.width = 498
	canvas.height = 750
	document.body.appendChild(canvas)

loadGraphics = ->
	# load background image
	bg.img = new Image()
	bg.img.src = 'img/background.png'
	bg.img.onload = -> bg.ready = true
	
	# load pad
	pad.img = new Image()
	pad.img.src = 'img/pad.png'
	pad.img.onload = -> pad.ready = true
	
	# load ball
	ball.img = new Image()
	ball.img.src = 'img/ball.png'
	ball.img.onload = -> ball.ready = true

# update game objects
update = (modifier) ->
	pad.x -= 255 * modifier if keysDown[37]? # player holding left
	pad.x += 255 * modifier if keysDown[39]? # player holding right

render = ->
	canvasContext.drawImage(bg.img, 0, 0) if bg.ready
	canvasContext.drawImage(pad.img, pad.x, pad.y) if pad.ready
	canvasContext.drawImage(ball.img, ball.x, ball.y) if ball.ready

previous = Date.now()

mainLoop = ->
	now = Date.now()
	delta = now - previous

	update(delta / 1000)
	render()

	previous = now

window.init = ->
	createCanvas()
	loadGraphics()
	
	setInterval(mainLoop, 1) # execute as fast as possible