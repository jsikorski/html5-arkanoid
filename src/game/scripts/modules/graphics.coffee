class Element
	ready : false

	constructor: (@model, src) ->
		@img = new Image()
		@img.src = src
		@img.onload = => @ready = true

	render: (canvasContext) ->
		canvasContext.drawImage(@img, @model.x, @model.y, @model.width, @model.height) if @ready

class Renderer
	elements: []

	constructor: (@canvasContext, elements) ->
		@addElements(elements)

	addElements: (elements) ->
		@elements = @elements.concat(elements)

	render: ->
		element.render(@canvasContext) for element in @elements


exportForModule 'Arkanoid.Graphics', Element, Renderer