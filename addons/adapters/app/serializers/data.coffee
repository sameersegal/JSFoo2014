DataSerializer = DS.RESTSerializer.extend DS.EmbeddedRecordsMixin,
	
	primaryKey: "_id"

	extractFindQuery: (store, type, payload, id, requestType) ->
		that = @
		_payload = {}
		_rootKey = Ember.String.pluralize type.typeKey
		_payload[_rootKey] = (payload.rows or []).map (row) -> that.addIds row.doc
		@extractArray(store, type, _payload, id, requestType)

	hasEmbeddedAlwaysOption: () ->
		true

	addIds: (payload) ->
		# we need to add ids at every level
		for prop, val of payload when typeof val is "object"
			id = payload.id or payload._id
			if val.length isnt undefined
				# hasMany relationship
				count = 1
				for row in val
					row.id = md5(id + "prop" + count)
					@addIds row
					count++
			else
				# belongsTo relationship
				val.id = md5(id + "prop")
				@addIds val

		payload


`export default DataSerializer`