`import DataAdapter from './data'`

LucyAdapter = DataAdapter.extend

  defaultSerializer: "lucy"

  buildURL: (type, id, query) ->
        # host = @.get "host" 
        if query.category or query.view  
            if query.category and query.view
                category = query.category
                view = query.view
                delete query.category
                delete query.view

                # clean keys in query
                query.data = {}
                for key, value of query when key in ["q","sort","limit","default_operator","include_docs"]
                  query.data[key] = query[key]
                  delete query[key]

                url = "http://localhost:5984/_fti/local/jsfoo/_design/#{category}/#{view}"
                console.log url
                url
            else
                throw new Error("Need to specify both category and view to make a /_search query")
        else
          @_super type, id, query
  
`export default LucyAdapter`