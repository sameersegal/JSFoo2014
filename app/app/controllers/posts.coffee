Controller = Ember.ArrayController.extend

	searchResults: Ember.A []

	actions:
		query: (q, tag) ->
			query = 
				ddoc: "list"
				view: "byCaption"
				q: "#{q}*"
				limit: 10
				include_docs: true

			that = @
			@store.find("post-lucy", query)
				.then (rows) ->
					array = rows.map (row) ->
						caption = row.get("caption").substring(0,50)
						Ember.Object.create
							id: row.get "id"
							caption: caption
							votes: row.get "votes.count"
							imageLink: row.get("images").filterBy("type","normal")[0].get("link")
					that.set "searchResults", Ember.A array

		selected: (item, tag) ->
			@transitionToRoute "posts.post", item

`export default Controller`