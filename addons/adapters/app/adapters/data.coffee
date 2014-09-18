DataAdapter = DS.RESTAdapter.extend

  primaryKey: "_id"
  defaultSerializer: "data"

  host: "http://127.0.0.1:5984"
  namespace: "db"

  buildURL: (type, id, query) ->    
    host = @.get "host"
    namespace = @.get "namespace"
      
    if query       
        # _view
        ddoc = query.ddoc
        view = query.view
        delete query.ddoc
        delete query.view

        # clean keys in query
        query.data = {}
        for key, value of query when key in ["reduce","key","startkey","endkey","keys","limit","skip","group_level","include_docs","descending"]
          query.data[key] = query[key]
          delete query[key]

        "#{host}/#{namespace}/_design/#{ddoc}/_view/#{view}"
    else
      if id
        "#{host}/#{namespace}/#{id}"
      else
        "#{host}/#{namespace}"

  findAll: (store, type, sinceToken) ->
    Ember.assert("Please do not call find() for '#{type.typeKey}' instead pass keys or startkey & endkey pair",false)

  findQuery: (store, type, query) ->
    url = @buildURL type, null, query

    # type changes from GET to POST when we are querying _all_docs
    type = query.type or "GET"
    delete query.type

    @ajax url, type, query

  createRecord: (store, type, record) ->
    data = {}
    serializer = store.serializerFor type.typeKey
    data = serializer.serialize record, includeId: true
    
    @ajax @buildURL(type.typeKey), "POST", (json) ->
         # Update the relevant parameters
         Ember.assert "Must contain ok key in save response", json.ok
         delete json.ok
         Ember.assert "Must contain id key in save response", json.id
         Ember.assert "Must contain rev key in save response", json.rev
         
         data._rev = json.rev
         delete json.rev

         json = $.extend data, json

         json 
      , data: data

  updateRecord: (store, type, record) ->
    data = {}
    serializer = store.serializerFor type.typeKey
    data = serializer.serialize record, includeId: true
    id = record.get 'id'

    @ajax @buildURL(type.typeKey, id, query), "PUT", (json) ->
         # Update the relevant parameters
         Ember.assert "Must contain ok key in save response", json.ok
         delete json.ok
         Ember.assert "Must contain id key in save response", json.id
         Ember.assert "Must contain rev key in save response", json.rev
         
         data._rev = json.rev
         delete json.rev

         json = JSON.parse JSON.stringify $.extend data, json

         json 
      , data: data  

  deleteRecord: (store, type, record) ->
    data = {}
    serializer = store.serializerFor type.typeKey
    data = serializer.serialize record, includeId: true

    # We add the _deleted flag to preserve the document instead 
    # of deleting it completely
    data._deleted = true
    id = record.get 'id'

    @ajax @buildURL(type.typeKey, id), "PUT", (json) ->
         # Update the relevant parameters
         Ember.assert "Must contain ok key in save response", json.ok
         delete json.ok
         # Ember.assert "Must contain id key in save response", json.id
         Ember.assert "Must contain rev key in save response", json.rev
         
         data._rev = json.rev
         delete json.rev

         json = $.extend data, json

         json 
      , data: data


  ajax: (url, type, normalizeResponse, hash) ->
    adapter = @

    if normalizeResponse and not hash
      hash = normalizeResponse
      normalizeResponse = null

    new Ember.RSVP.Promise (resolve,reject) ->
         hash = adapter.ajaxOptions url, type, hash

         hash.success = (json) ->
           json = normalizeResponse.call(adapter,json) if normalizeResponse and Em.typeOf(normalizeResponse) is "function"
           Ember.run null, resolve, json

         hash.error = (jqXHR, textStatus, errorThrown) ->
           Ember.run null,reject,adapter.ajaxError(jqXHR)

         Ember.$.ajax hash

      , "DS: DataAdapter#ajax #{type} to #{url}"

`export default DataAdapter`