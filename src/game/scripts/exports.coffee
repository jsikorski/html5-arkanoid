ensureModuleExists = (name, parent) ->
	parts = name.split('.')
	
	head = parts[0]
	parent[head] ?= {}

	return if parts.length is 1
	tail = parts[1..].join('.')
	ensureModuleExists(tail, parent[head])

getModule = (name) ->
	parts = name.split('.')
	
	currentModule = window
	currentModule = currentModule[part] for part in parts
	currentModule

initializeType = (type, module) ->
	module[type.name] = type

window.exportForModule = (moduleName, types...) ->
	if not moduleName or moduleName is ''
		throw "Module name is required."

	ensureModuleExists(moduleName, window)
	module = getModule(moduleName)
	initializeType(type, module) for type in types