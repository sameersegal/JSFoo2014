# Bootstrap3 removed typeahead plugin / component
# Twitter had created a more powerful typeahead.js plugin
# But this plugin's css is not compatible with Bootstrap3
# 
# We used typeahead.js (jQuery plugin is sufficient, Ember handles the API calls)
# And we use https://github.com/hyspace/typeahead.js-bootstrap3.less
# to correct the css

Component = Ember.Component.extend

	tagName: "input"
	classNames: ["typeahead"]
	classNameBindings: ["isLoading:loading:"]
	attributeBindings: ["placeholder"]

	name: null
	content: null
	itemTemplate: null
	emptyTemplate: null

	isLoading: false

	didInsertElement: () ->
		that = @
		@$().typeahead({
				hint: true
				highlight: true
				minLength: 1
			},
			{
				name: "typeahead"
				source: (q, cb) ->
					name = that.get "name"					

					# We store the latest callback as source
					that.set "source", cb

					# Action is responsible to update the content
					that.sendAction "query", q, name

					that.set "isLoading", true
					return
				templates: 
					empty: if that.get("emptyTemplate") then Handlebars.compile(that.get("emptyTemplate")) else "<p>Sorry, no match found</p>"
					suggestion: if that.get("itemTemplate") then Handlebars.compile(that.get("itemTemplate")) else null
				
			}
		).on("typeahead:selected", (event,item) ->
			name = that.get "name"
			that.sendAction "selected", item, name
		).on("typeahead:autocompleted", (event,item) ->
			name = that.get "name"
			that.sendAction "selected", item, name
		)

	contentDidChange: ( ->
		content = @get "content" 
		source = @get "source"

		if source and content
			source content
		@set "isLoading", false
	).observes("content.@each.value")

`export default Component`