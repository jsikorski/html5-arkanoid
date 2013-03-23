##### Basic models ######

class Model
	x: 0
	y: 0
	height: 0
	width: 0
	
	constructor: ->
		@collidingModels = []

	update: ->
		@handleCollisions()

	addCollidingModel: (model) ->
		@collidingModels.push(model)

	handleCollisions: ->
		@handleCollision(model) for model in @collidingModels
		@collidingModels.length = 0

	handleCollision: (collidingModel) ->
		modelTypeName = collidingModel.constructor.name
		methodName = "handle#{modelTypeName}Collision"
		method = @[methodName]
		method.call(@) if method?

	collides: (c) ->
		(
			(
				(
					(@x >= c.x) and
					(@x <= c.x + c.width)
				) or
				(
					(@x + @width >= c.x) and
					(@x + @width <= c.x + c.width)
				) or
				(
					(@x <= c.x) and 
					(@x + @width >= c.x + c.width)
				) or
				(
					(@x >= c.x) and 
					(@x + @width <= c.x + c.width)
				)
			)and
			(
				(
					(@y >= c.y) and
					(@y <= c.y + c.height)
				)or
				(
					(@y + @height >= c.y) and
					(@y + @height <= c.y + c.height)
				)or
				(
					(@y <= c.y) and 
					(@y + @height >= c.y + c.height)
				)or
				(
					(@y >= c.y) and 
					(@y + @height <= c.y + c.height)
				)
			)
		)

class Pad extends Model
	x: 250
	y: 700
	height: 27
	width: 129

	update: (modifier, control)->
		super()
		# TODO magic numbers!
		delta = 255 * modifier
		@moveLeft(delta) if control.isLeftActive()
		@moveRight(delta) if control.isRightActive()

	moveLeft: (delta) ->
		@x -= delta

	moveRight: (delta) ->
		@x += delta

class Ball extends Model
	x: 275
	y: 680
	height: 36
	width: 38

	velX: 0
	velY: 0

	update: (modifier, control)->
		super()

		if (control.isStartActive())
			control.reset('start')
			@velX = 255
			@velY = -255

		@x += @velX * modifier
		@y += @velY * modifier

	handleTopEdgeCollision: ->
		@velY = -@velY

	handleBottomEdgeCollision: ->
		@isAlive = false

	handleVerticalEdgeCollision: ->
		@velX = -@velX

	handlePadCollision: ->
		@velY = -@velY		

##### Edges #####

class TopEdge extends Model
	constructor: (@width) ->
		super()

class BottomEdge extends Model
	constructor: (@y, @width) ->
		super()

class VerticalEdge extends Model
	constructor: (@x, @height) ->
		super()

class EdgesBuilder
	@buildFor: (boardWidth, boardHeight) ->
		return [
			new TopEdge(boardWidth)
			new VerticalEdge(0, boardHeight)
			new VerticalEdge(boardWidth, boardHeight)
			new BottomEdge(boardHeight)
		]

##### Services #####

class CollisionsDetector
	collisionsPairs: []

	addPair: (model1, model2) ->
		@collisionsPairs.push([model1, model2])

	addMany: (model, models) ->
		@addPair(model, model2) for model2 in models

	check: ->
		for pair in @collisionsPairs
			do ->
				pair[0].addCollidingModel(pair[1]) if pair[0].collides(pair[1])
				pair[1].addCollidingModel(pair[0]) if pair[1].collides(pair[0])

class Updater
	models: []

	constructor: (models) ->
		@addModels(models)

	addModels: (models)  ->
		@models = @models.concat(models)

	update: (modifier, control) ->
		model.update(modifier, control) for model in @models	


exportForModule 'Arkanoid.Models', Model, Pad, Ball, EdgesBuilder, CollisionsDetector, Updater