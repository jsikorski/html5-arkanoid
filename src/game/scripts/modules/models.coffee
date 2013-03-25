##### Basic models ######

class Model
	x 		: 0
	y 		: 0
	height 	: 0
	width 	: 0
	
	constructor: ->
		@collidingModels = []

	update: ->
		@handlePositionBinding()
		@handleCollisions()

	handlePositionBinding: ->
		return if not @positionBinding
		@x = @positionBinding.model.x + @positionBinding.offsetX
		@y = @positionBinding.model.y + @positionBinding.offsetY

	move: (xDelta, yDelta) ->
		return if @positionBinding
		@x += xDelta
		@y += yDelta

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

	bindPositionTo: (model, offsetX, offsetY) ->
		@positionBinding =
			model: model
			offsetX: offsetX,
			offsetY: offsetY

	unbindPosition: ->
		delete @positionBinding

class Pad extends Model
	x 	 	: 200
	y 		: 700
	height 	: 60
	width 	: 129
	speed 	: 255

	update: (modifier, control)->
		super()
		
		if control.isRightActive() and not @rightCollisionDetected
			@move(@speed * modifier, 0)
		
		if control.isLeftActive() and not @leftCollisionDetected
			@move(-@speed * modifier, 0)

		delete @rightCollisionDetected
		delete @leftCollisionDetected

	handleRightEdgeCollision: ->
		@rightCollisionDetected = true

	handleLeftEdgeCollision: ->
		@leftCollisionDetected = true

class Ball extends Model
	x 		: 250
	y 		: 660
	height 	: 36
	width 	: 38
	velX	: 0
	velY	: 0

	update: (modifier, control)->
		super()

		if control.isStartActive() and not @started
			@started = true
			control.reset('start')
			@velX = 150
			@velY = -150
			@unbindPosition()

		@move(@velX * modifier, @velY * modifier) if @started

	handleTopEdgeCollision: ->
		@velY = -@velY

	handleRightEdgeCollision: ->
		@handleVerticalEdgeCollision()

	handleVerticalEdgeCollision: ->
		@velX = -@velX

	handleBottomEdgeCollision: ->
		@isAlive = false

	handleLeftEdgeCollision: ->
		@handleVerticalEdgeCollision()

	handlePadCollision: ->
	 	@velY = -@velY if @velY > 0

##### Edges #####

class TopEdge extends Model
	constructor: (@width) ->
		super()

class RightEdge extends Model
	constructor: (@x, @height) ->
		super()

class BottomEdge extends Model
	constructor: (@y, @width) ->
		super()

class LeftEdge extends Model
	constructor: (@height) ->
		super()

class EdgesBuilder
	@buildFor: (boardWidth, boardHeight) ->
		return [
			new TopEdge(boardWidth)
			new RightEdge(boardWidth, boardHeight)
			new BottomEdge(boardHeight)
			new LeftEdge(boardHeight)
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