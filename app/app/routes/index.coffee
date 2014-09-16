Route = Ember.Route.extend

	redirect: () ->
		@transitionTo "posts"

`export default Route`