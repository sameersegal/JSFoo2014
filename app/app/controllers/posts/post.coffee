Controller = Ember.ObjectController.extend

	normalImage: (->
		if @get("imageLink")
			@get("imageLink")
		else
			@get("images")?.filterBy("type","normal")[0]?.get("link")
	).property("images.@each")

`export default Controller`