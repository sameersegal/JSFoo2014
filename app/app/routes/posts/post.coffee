Route = Ember.Route.extend

	model: (params) ->
		@store.find "post", params.post_id

`export default Route`