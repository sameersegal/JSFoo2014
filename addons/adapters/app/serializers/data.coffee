DataSerializer = DS.RESTSerializer.extend DS.EmbeddedRecordsMixin,
  
  primaryKey: "_id"

  extractFindQuery: (store, type, payload, id, requestType) ->
    _payload = {}
    _payload[Ember.String.pluralize(type.typeKey)] = (payload.rows or []).map (row) -> row.doc
    @extractArray(store, type, _payload, id, requestType)

`export default DataSerializer`