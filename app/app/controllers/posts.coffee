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
						console.log row
						Ember.Object.create
							caption: row.get "value.caption"
					that.set "searchResults", Ember.A array

		# selected: (item, tag) ->
		# 	@transitionTo "posts", {}

`export default Controller`