DataSerializer = DS.RESTSerializer.extend
  
  primaryKey: "_id"

  normalizePayload: (store, type, hash) ->
    # store is optional and we need to correct the other params if it isnt present
    if not hash
      hash = type
      type = store
      store = undefined

    serializer = @

    hash.id = hash._id or hash.id
    delete hash._id

    id = hash.id or new Date().getTime()

    _payload = {}
    _root = _payload[type.typeKey] = hash

    # We need to convert a generic embedded payload from couchdb into 
    # Ember's sideload format. We need to take care of a scenario with nth level of nesting
    # and reusing same models in different part of the json. Simultaneously ensuring their ids
    # remain unique across this model and across all models.

    # [todo] - refactor normalizePayload function. Its design can be definitely be improved
    type.eachRelationship (key, relationship) ->
      subTypeKey = relationship.type.typeKey

      val = _root[key]

      if relationship.kind is "hasMany"
        subTypeKeyz = Em.String.pluralize subTypeKey
        subs = _payload[subTypeKeyz] = _payload[subTypeKeyz] or []        
        i = subs.length + 1
        ids = []
        val = _root[key]
        if val
          for row in val
            # decide id first and then send it on a recursive loop            
            row.id = md5 id + relationship.parentType.typeKey + relationship.key + i
            if relationship.options.polymorphic
              pSubTypeKey = row.type or subTypeKey
              ids.push
                id: row.id
                type: pSubTypeKey
            else 
              pSubTypeKey = subTypeKey
              ids.push row.id
            i++

            if store
              cleansed_val = serializer.normalizePayload store, store.modelFor(pSubTypeKey), row
              Em.keys(cleansed_val).forEach (key) ->
                if key is subTypeKey
                  if Em.typeOf(cleansed_val[key]) is "array"
                    for row in cleansed_val[key]
                      subs.push row
                  else
                    subs.push cleansed_val[key]
                else
                  keyz = Em.String.pluralize key
                  _subs = _payload[keyz] = _payload[keyz] or []
                  if Em.typeOf(cleansed_val[key]) is "array"
                    for row in cleansed_val[key]
                      _subs.push row
                  else
                    _subs.push cleansed_val[key]
          _root[key] = ids
        delete _payload[subTypeKeyz] if subs.length is 0

      else if relationship.kind is "belongsTo"
          subs = _payload[subTypeKey] = _payload[subTypeKey] or []
          val = _root[key]
          if val
            # decide id first and then send it on a recursive loop
            val.id = _root[key] = id + (subs.length + 1)
            # [todo] - drop this condition because store needs to be passed always
            if store
              cleansed_val = serializer.normalizePayload store, store.modelFor(subTypeKey), val
              Em.keys(cleansed_val).forEach (key) ->
                if key is subTypeKey
                  if Em.typeOf(cleansed_val[key]) is "array"
                    for row in cleansed_val[key]
                      subs.push row
                  else
                    subs.push cleansed_val[key]
                else
                  keyz = Em.String.pluralize key
                  _subs = _payload[keyz] = _payload[keyz] or []
                  if Em.typeOf(cleansed_val[key]) is "array"
                    for row in cleansed_val[key]
                      _subs.push row
                  else
                    _subs.push cleansed_val[key]

          delete _payload[subTypeKey] if subs.length is 0
    @_super type, _payload

  normalizeId: (hash) ->
    hash.id = hash._id or hash.id
    delete hash._id

    hash

  extractSingle: (store,primaryType,payload,recordId,requestType) ->
    payload = @normalizePayload(store, primaryType, payload)
    primaryTypeName = primaryType.typeKey
    primaryRecord = undefined
    for prop of payload
      typeName = @typeForRoot(prop)
      isPrimary = typeName is primaryTypeName
      
      # legacy support for singular resources
      if isPrimary and Ember.typeOf(payload[prop]) isnt "array"
        primaryRecord = @normalize(primaryType, payload[prop], prop)
        continue
      type = store.modelFor(typeName)
      
      serializer = @
      payload[prop].forEach (hash) ->
        typeName = serializer.typeForRoot(prop)
        type = store.modelFor(typeName)
        typeSerializer = store.serializerFor(type)
        hash = typeSerializer.normalize(type, hash, prop)
        isFirstCreatedRecord = isPrimary and not recordId and not primaryRecord
        isUpdatedRecord = isPrimary and coerceId(hash.id) is recordId
        
        # find the primary record.
        #
        # It's either:
        # * the record with the same ID as the original request
        # * in the case of a newly created record that didn't have an ID, the first
        #   record in the Array
        if isFirstCreatedRecord or isUpdatedRecord
          primaryRecord = hash
        else
          store.push typeName, hash
    primaryRecord

  extractArray: (store,type,payload) ->
    payload = payload.rows if payload
    rows = []
    for row in payload
      row = row.doc
      row = @normalize type, row
      row = @normalizePayload store, type, row

      primaryModel = row[type.typeKey]
      delete row[type.typeKey]

      # we are directly pushing all the relationships
      # into the store and at the end will load the array 
      # of primary models
      for key, values of row
        secondaryType = Ember.String.singularize key
        store.pushMany secondaryType, values

      rows.push primaryModel
    rows

  extractMeta: (store, type, payload) ->
    if payload
      meta = {}
      meta.total_rows = payload.total_rows if payload.total_rows
      meta.offset = payload.offset if payload.offset
      store.metaForType(type, meta)
      delete payload.total_rows
      delete payload.offset

  serialize: (record, options) ->
    json = @_super.apply this, arguments

    if json._rev is null
      delete json._rev
    if json._attachments is null
      delete json._attachments
    json

  serializeHasMany: (record, json, relationship) ->
    key = relationship.key

    serializer = @

    relationshipType = DS.RelationshipChange.determineRelationshipType record.constructor, relationship

    if relationshipType is 'manyToNone' or relationshipType is 'manyToMany'
      if record.get(key).get("length") > 0
        json[key] = record.get(key).map (row) ->
          json = serializer.serialize row, includeId:false

          if relationship.options.polymorphic
            serializer.serializePolymorphicType row, json, relationship

          json
      else
        # making it null is better than to just leave it empty
        json[key] = []
        json

  serializeBelongsTo: (record, json, relationship) ->
    key = relationship.key

    belongsTo = record.get key

    key = if @keyForRelationship then @keyForRelationship key, "belongsTo" else key

    if belongsTo
      data = @serialize belongsTo, includeId:false
      # delete data.id

      if relationship.options.polymorphic
        @serializePolymorphicType belongsTo, data, relationship
      
      json[key] = data

  serializePolymorphicType: (record, json, relationship) ->
    json.type = Ember.String.underscore record.constructor.typeKey

`export default DataSerializer`