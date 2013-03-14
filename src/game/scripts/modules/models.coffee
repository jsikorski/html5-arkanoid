class Model
	x: 0
	y: 0

class Pad extends Model
	x: 250
	y: 700

	moveLeft: (delta) ->
		@x -= delta

	moveRight: (delta) ->
		@x += delta

class Ball extends Model
	x: 200
	y: 200


exportForModule 'Arkanoid.Models', Model, Pad, Ball