`import DataSerializer from './data'`

LucySerializer = DataSerializer.extend

	extractArray: (store, primaryType, payload) ->
		modifiedPayload = {}
		modifiedPayload.offset = payload.skip
		modifiedPayload.total_rows = payload.total_rows
		modifiedPayload.rows = for row in payload.rows
			id: row.id
			key: @keyFromRow row
			value: @valueFromRow row
		@_super store, primaryType, modifiedPayload

	keyFromRow: (row) ->
		[row.id]

	valueFromRow: (row) ->
		row.fields

`export default LucySerializer`