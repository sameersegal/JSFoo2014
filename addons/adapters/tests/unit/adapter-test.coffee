`import { test, moduleFor } from 'ember-qunit'`

moduleFor "adapter:data", "Unit - DataAdapter",
	setup: () -> console.log "Foo"
	teardown: () ->

test "it exists", () ->
	console.log "I am here"
	ok @subject()