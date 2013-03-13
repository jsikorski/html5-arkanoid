module 'Arkanoid.Graphics'

class Arkanoid.Graphics.Renderer
	constructor: (@canvasContext) ->
		@elements = []

	addElements: (elements...) ->
		@elements.push(element) for element in elements

	render: (canvasContext) ->
		element.render(canvasContext) for element in @elements