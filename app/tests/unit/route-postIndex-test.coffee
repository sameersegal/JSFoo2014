`import { test, moduleFor } from 'ember-qunit'`

moduleFor "route:posts/index", "Unit - Route -  Posts/Index",
	setup: () -> console.log "Foo"
	teardown: () ->

test "it exists", () ->
	console.log "I am here"
	ok @subject()