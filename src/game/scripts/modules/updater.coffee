class Updater

	models: []

	addModels: (models...)  ->
		@models.push(model) for model in models

	update: (modifier,control) ->
		model.update(modifier,control) for model in @models

exportForModule 'Arkanoid.Physics', Updater
