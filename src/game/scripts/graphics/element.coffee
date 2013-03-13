module 'Arkanoid.Graphics'

class Arkanoid.Graphics.Element
	ready : false

	constructor: (@model, src) ->
		@img = new Image()
		@img.src = src
		@img.onload = => @ready = true

	render: (canvasContext) ->
		canvasContext.drawImage(@img, @model.x, @model.y) if @ready