class Model
	x: 0
	y: 0
	height:0
	width:0

	collides: (c) ->
		(
			(
				(
					(@x > @c.x) and
					(@x < @c.x + @c.width)
				) or
				(
					(@x + @width > @c.x) and
					(@x + @width < @c.x + @c.width)
				) or
				(
					(@x < @c.x) and 
					(@x + @width > @c.x + @c.width)
				) or
				(
					(@x > @c.x) and 
					(@x + @width < @c.x + @c.width)
				)
			)and
			(
				(
					(@y > @c.y) and
					(@y < @c.y + @c.height)
				)or
				(
					(@y + @height > @c.y) and
					(@y + @height < @c.y + @c.height)
				)or
				(
					(@y < @c.y) and 
					(@y + @height > @c.y + @c.height)
				)or
				(
					(@y > @c.y) and 
					(@y + @height < @c.y + @c.height)
				)
			)
		)

class Pad extends Model
	x: 250
	y: 700
	height:27
	width:129

	moveLeft: (delta) ->
		@x -= delta

	moveRight: (delta) ->
		@x += delta

	update: (modifier,control)->
		# TODO magic numbers!
		delta = 255 * modifier
		@moveLeft(delta) if control.isLeftActive()
		@moveRight(delta) if control.isRightActive()

class Ball extends Model
	x: 275
	y: 680
	height:36
	width:38

	velX:0
	velY:0

	update: (modifier,control)->

		if (control.isStartActive())
			control.resetForAll('start')
			@velX = 255
			@velY = -255

		@x += @velX * modifier
		@y += @velY * modifier

		# wall collisions
		if (@x > 498)
			@x = 2*498 - @x
			@velX = -@velX

		if (@x < 0)
			@x = - @x
			@velX = -@velX	

		if (@y < 0)
			@y = - @y
			@velY = -@velY

		# pad collisions

		if (@y > 750)
			Arkanoid.Game.looseLife()
			

exportForModule 'Arkanoid.Models', Model, Pad, Ball