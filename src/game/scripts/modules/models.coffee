##### Basic models ######

class Model
	x 		: 0
	y 		: 0
	height 	: 0
	width 	: 0

	
	constructor: ->
		@potentiallyCollidingModels = []
		@actuallyCollidingModels = []
		@isAlive = true

	move: (xDelta, yDelta) ->
		return if @positionBinding
		@x += xDelta
		@y += yDelta

	bindPositionWith: (model, offsetX, offsetY) ->
		@positionBinding =
			model 	: model
			offsetX : offsetX
			offsetY : offsetY

	unbindPosition: ->
		delete @positionBinding

	addCollidingModels: (models) ->
		models = [models] if not _.isArray(models)
		@potentiallyCollidingModels = @potentiallyCollidingModels.concat(models)

	removeCollidingModel: (model) ->
		@potentiallyCollidingModels.splice(@potentiallyCollidingModels.indexOf(model),1)	

	update: ->
		@handlePositionBinding()
		@checkCollisions()
		@handleCollisions()

	handlePositionBinding: ->
		return if not @positionBinding
		@x = @positionBinding.model.x + @positionBinding.offsetX
		@y = @positionBinding.model.y + @positionBinding.offsetY

	checkCollisions: ->
		for model in @potentiallyCollidingModels
			do =>
				@actuallyCollidingModels.push(model) if @collides(model)

	handleCollisions: ->
		@handleCollision(model) for model in @actuallyCollidingModels
		@actuallyCollidingModels.length = 0

	handleCollision: (collidingModel) ->
		modelTypeName = collidingModel.constructor.name
		methodName = "handle#{modelTypeName}Collision"
		method = @[methodName]
		method.call(@,collidingModel) if method?

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
			)and 
			(
				c.isAlive
			)
		)

class Pad extends Model
	x 	 	: Arkanoid.Board.width / 2
	y 		: Arkanoid.Board.height * 19/20
	height 	: Arkanoid.Board.height /20
	width 	: Arkanoid.Board.width / 8
	speed 	: Arkanoid.Board.width / 2
	canShoot: false

	update: (modifier, control)->
		super()
		
		if control.isRightActive() and not @rightCollisionDetected
			@move(@speed * modifier, 0)
		
		if control.isLeftActive() and not @leftCollisionDetected
			@move(-@speed * modifier, 0)

		if control.isShootActive() and @canShoot
			@game.shoot(@)
			@canShoot = false

		delete @rightCollisionDetected
		delete @leftCollisionDetected

	handleRightEdgeCollision: (collidingModel) ->
		@rightCollisionDetected = true

	handleLeftEdgeCollision: (collidingModel) ->
		@leftCollisionDetected = true

	handlePowerUpCollision: (collidingModel) ->
		@canShoot = true
		@game.getPowerUp(collidingModel)

	setGameHandler: (game) ->
		@game = game

class Ball extends Model
	x 		: Arkanoid.Board.width / 2
	y 		: Arkanoid.Board.height * 9/10
	height 	: Arkanoid.Board.height /30
	width 	: Arkanoid.Board.height /30
	velX	: 0
	velY	: 0

	update: (modifier, control)->
		super()

		if control.isStartActive() and not @started
			@started = true
			control.reset('start')
			@velX = Arkanoid.Board.width / 4 
			@velY = -Arkanoid.Board.width / 4
			@unbindPosition()

		@move(@velX * modifier, @velY * modifier) if @started

	reset: ->
		@velX = 0
		@velY = 0
		@started = false

	handleTopEdgeCollision: (collidingModel) ->
		@velY = -@velY if @velY < 0

	handleRightEdgeCollision: (collidingModel) ->
		@velX = -@velX

	handleBottomEdgeCollision: (collidingModel) ->
		@game.looseLife()

	handleLeftEdgeCollision: (collidingModel) ->
		@velX = -@velX

	handlePadCollision: (collidingModel) ->
		padCenter = ((collidingModel.width/2) + collidingModel.x)
		ballCenter = (@width/2) + @x

		xModifierPercentage = (ballCenter - padCenter)/collidingModel.width

		xModifier = 0
		if (@velX > 0) 
			xModifier = @velX
		else 
			xModifier = -@velX

		xModifier = xModifier * xModifierPercentage

		if (xModifierPercentage > 0.5 or xModifierPercentage < -0.5)
			@velX = @velX + xModifier
		if @velY > 0
			@velY = -@velY
			@game.hitPad()
		
	handleTargetCollision: (collidingModel) ->

		side = @collidingSide(collidingModel)
		switch side
			when 2 then @velY = -@velY if (@velY > 0)
			when 8 then @velY = -@velY if (@velY < 0) 
			when 4 then @velX = -@velX if (@velX > 0) 
			when 6 then @velX = -@velX if (@velX < 0) 
			when 1 
				if (@velX > 0)
					@velX = -@velX
				if (@velY > 0)
					@velY = -@velY
			when 3 
				if (@velX < 0)
					@velX = -@velX
				if (@velY > 0)
					@velY = -@velY
			when 5 then @velY = -@velY
			when 7 
				if (@velX > 0)
					@velX = -@velX
				if (@velY < 0)
					@velY = -@velY
			when 9
				if (@velX < 0)
					@velX = -@velX
				if (@velY < 0)
					@velY = -@velY
		@game.hitTarget(collidingModel)
		

	setGameHandler: (game) ->
		@game = game

# colliding sides map:
# 	1 2 3
#   4 5 6
#	7 8 9
	collidingSide: (c) ->
		if (@inLowerBound(c,'x') and @inLowerBound(c,'y'))
			return 1
		if (@inside(c,'x') and @inLowerBound(c,'y'))
			return 2
		if (@inHigherBound(c,'x') and @inLowerBound(c,'y'))
			return 3
		if (@inLowerBound(c,'x') and @inside(c,'y'))
			return 4
		if (@inside(c,'x') and @inside(c,'y'))
			return 5
		if (@inHigherBound(c,'x') and @inside(c,'y'))
			return 6	
		if (@inLowerBound(c,'x') and @inHigherBound(c,'y'))
			return 7
		if (@inside(c,'x') and @inHigherBound(c,'y'))
			return 8
		if (@inHigherBound(c,'x') and @inHigherBound(c,'y'))
			return 9	


	inLowerBound:(c,axis) ->
		if (axis == 'x')
			return (
				(@x < c.x) and
				(@x + @width >= c.x)
			)
		else if (axis == 'y')
			return (
				(@y < c.y) and
				(@y + @height >= c.y)
			)

	inside:(c,axis) ->
		if (axis == 'x')
			return (
				(@x > c.x) and 
				(@x + @width < c.x + c.width)
			)
		else if (axis == 'y')
			return (
				(@y > c.y) and 
				(@y + @height < c.y + c.height)
			)

	inHigherBound:(c,axis) ->
		if (axis == 'x')
			return (
				(@x > c.x) and
				(@x < c.x + c.width) and
				(@x + @width >= c.x + c.width)
			)
		else if (axis == 'y')
			return (
				(@y > c.y) and
				(@y < c.y + c.height) and
				(@y + @height >= c.y + c.height)
			)
						

class Target extends Model

	height 	: Arkanoid.Board.height /20
	width 	: Arkanoid.Board.width /9
	hasPowerUp : false

	setGameHandler: (game) ->
		@game = game

	constructor: (@x,@y) ->
		super()
		@isHit = false

	handleBulletCollision: (collidingModel) ->
		@game.hitTarget(@)
		@game.deleteBullet(collidingModel)

class Life extends Model

	height 	: Arkanoid.Board.height /20
	width 	: Arkanoid.Board.width /20

	constructor: (@x,@y) ->
		super()

class Popup extends Model
	y 	: Arkanoid.Board.height /3
	x 	: Arkanoid.Board.width /3
	height 	: Arkanoid.Board.height /3
	width 	: Arkanoid.Board.width /3

	update: (modifier, control)->
			super()
			if control.isStartActive()
				location.reload()

class PowerUp extends Model
	height 	: Arkanoid.Board.height /20
	width 	: Arkanoid.Board.width /40
	velY	: Arkanoid.Board.height / 4

	constructor: (target) ->
		super()
		@x = target.x + target.width/2
		@y = target.y + target.height/2

	update: (modifier, control)->
		@move(0,  @velY * modifier)

		if (@y > Arkanoid.Board.height)
			@isAlive = false

class Bullet extends Model
	height 	: Arkanoid.Board.height /20
	width 	: Arkanoid.Board.width /40
	velY	: -Arkanoid.Board.height / 4

	constructor: (pad) ->
		super()
		@x = pad.x + pad.width/2
		@y = pad.y - pad.height/2

	update: (modifier, control)->
		@move(0,  @velY * modifier)

		if (@y < 0)
			@isAlive = false

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
			new BottomEdge(boardHeight, boardWidth)
			new LeftEdge(boardHeight)
		]

##### Services #####

class Level
	targets: []

	constructor: ->
		@targets = new Array()
		for i in [1..7]
			for j in [1..6]
				target = new Target(
						Arkanoid.Board.width * (i)/9,
						Arkanoid.Board.height * 2*(j)/30
						)
				if (i==j)
					target.hasPowerUp = true
				@targets.push target

	getTargets: ->
		return @targets

	remove: (target) ->
		@targets.splice(@targets.indexOf(target),1)

class LivesCounter
	lives: []

	constructor: (livesAmount)->

		@lives = new Array()
		for i in [1..livesAmount]
			life = new Life(
						Arkanoid.Board.width * (i-1) /20,
						Arkanoid.Board.height * 19 / 20
						)
			@lives.push life

	getLives: ->
		return @lives

	popLife: ->
		@lives.pop()

	isEmpty: ->
		return @lives.length == 0

class Updater
	models: []

	constructor: (models) ->
		@addModels(models)

	addModels: (models)  ->
		@models = @models.concat(models)

	remove: (m) ->
		@models.splice(@models.indexOf(m),1)

	update: (modifier, control) ->
		model.update(modifier, control) for model in @models

		temp = new Array()

		for m in @models
			if (not m.isAlive) 
				temp.push(m)

		for m in temp
			@remove(m)
		

exportForModule 'Arkanoid.Models', Model, Pad, Ball, EdgesBuilder, Level, LivesCounter, Updater, Popup, PowerUp, Bullet
