Controller = Ember.ObjectController.extend

	normalImage: (->
		@get("images")?.filterBy("type","normal")[0]?.get("link")
	).property("images.@each")

`export default Controller`