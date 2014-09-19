`import DataAdapter from './data'`

LucyAdapter = DataAdapter.extend

  buildURL: (type, id, query) ->
        host = @.get "host"
        namespace = @.get "namespace"

        if query.ddoc or query.view  
            if query.ddoc and query.view
                ddoc = query.ddoc
                view = query.view
                delete query.ddoc
                delete query.view

                # clean keys in query
                query.data = {}
                for key, value of query when key in ["q","sort","limit","default_operator","include_docs"]
                  query.data[key] = query[key]
                  delete query[key]

                url = "#{host}/_fti/local/#{namespace}/_design/#{ddoc}/#{view}"
            else
                throw new Error("Need to specify both ddoc and view to make a /_search query")
        else
          @_super type, id, query
  
`export default LucyAdapter`
