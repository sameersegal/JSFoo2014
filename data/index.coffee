request = require "request"
Q = require "q"

# 9GAG api parameters
API_HOST = "http://infinigag.eu01.aws.af.cm"
API_CATEGORY = "trending" # hot, vote, fresh
LIMIT = 100 # limit to scrape into DB

# local CouchDB parameters
DB_HOST = "http://127.0.0.1:5984"
DB = "jsfoo"

fetch = (lastSeq) ->
	d = Q.defer()

	request "#{API_HOST}/#{API_CATEGORY}/#{lastSeq}", (error, response, body) ->
		if error
			d.reject "Error: #{error}"
		else if response.statusCode isnt 200
			d.reject "Response Status Code: #{response.statusCode}"
		else
			json = JSON.parse body
			fns = []

			for row in json.data
				fns.push saveToDb row

			Q.all(fns)
				.then( () ->
					LIMIT = LIMIT - json.data.length
					console.log LIMIT
					if LIMIT >= 0
						fetch(json.paging.next)
					else
				).done () ->
					d.resolve()
				, (err) ->
					d.reject err
	d.promise

saveToDb = (doc) ->
	d = Q.defer()

	doc._id = doc.id
	delete doc.id

	delete doc.from
	delete doc.actions

	images = []
	for type in ["small","normal","large"] when doc.images[type] isnt  ""
		images.push type: type, link: doc.images[type]
	doc.images = images

	request 
			method: "POST"
			url: "#{DB_HOST}/#{DB}"
			json: doc
		, (error, response ,body) ->
			if error
				d.reject "Error: #{error}"
			else if response.statusCode isnt 201 and response.statusCode isnt 409 # ignoring data conflicts for now
				d.reject "Response Status Code: #{response.statusCode}"
			else
				d.resolve()	

	d.promise


fetch(0)
	.done () ->
			console.log "Done"
		, (err) ->
			console.log err

