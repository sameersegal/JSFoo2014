Route = Ember.Route.extend

	model: (params) ->
		@store.find "post", params.id

`export default Route`