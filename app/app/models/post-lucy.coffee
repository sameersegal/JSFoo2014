`import DS from 'ember-data'`

Model = DS.Model.extend

	caption: DS.attr "string"
	link: DS.attr "string"
	images: DS.hasMany "post-image"
	votes: DS.belongsTo "post-vote"

`export default Model`