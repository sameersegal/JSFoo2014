`import { test, moduleFor } from 'ember-qunit'`

moduleFor "adapter:data", "Unit - DataAdapter",
	setup: () ->
	teardown: () ->

test "it exists", () ->
	console.log "I am here"
	ok @subject()