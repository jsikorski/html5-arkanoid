module 'Arkanoid.Models'

class Model
	x: 0
	y: 0

class Arkanoid.Models.Background extends Model

class Arkanoid.Models.Pad extends Model
	x: 250
	y: 700

	moveLeft: (delta) ->
		@x -= delta

	moveRight: (delta) ->
		@x += delta

class Arkanoid.Models.Ball extends Model
	x: 200
	y: 200