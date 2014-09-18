`import DS from 'ember-data'`

Model = DS.Model.extend

	type: DS.attr "string"
	link: DS.attr "string"

`export default Model`