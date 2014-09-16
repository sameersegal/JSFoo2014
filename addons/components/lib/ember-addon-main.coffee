path = require('path')
fs = require('fs')

class Components

	constructor: (@project) ->
		@name = "Ember CLI Components"

	treeFor: (name) ->
		# treePath = path.join('node_modules', 'ember-cli-super-number', name + '-addon');
		# @unwatchedTree(treePath) if fs.existsSync(treePath) 

	unwatchedTree: (dir) ->
		read:	() -> dir
		cleanup: () ->

	included: (@app) ->
		# this.app.import('vendor/ember-cli-super-number/styles/style.css');

module.exports = Components