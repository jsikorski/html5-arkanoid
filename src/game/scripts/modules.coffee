ensureModuleExists = (name, parent) ->
	parts = name.split('.')
	
	head = parts[0]
	parent[head] ?= {}

	return if parts.length is 1
	tail = parts[1..].join('.')
	ensureModuleExists(tail, parent[head])

window.module = (name) ->
	if not name or name is ''
		throw "Module name is required."

	ensureModuleExists(name, window)