class Element
	ready : false

	constructor: (@model, src) ->
		@img = new Image()
		@img.src = src
		@img.onload = => @ready = true

	render: (canvasContext) ->
		canvasContext.drawImage(@img, @model.x, @model.y) if @ready

class Renderer
	elements: []

	constructor: (@canvasContext) ->

	addElements: (elements...) ->
		@elements.push(element) for element in elements

	render: ->
		element.render(@canvasContext) for element in @elements


exportForModule 'Arkanoid.Graphics', Element, Renderer