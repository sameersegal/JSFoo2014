import Ember from 'ember';

var Router = Ember.Router.extend({
  location: AppENV.locationType
});

Router.map(function() {
	this.resource("posts",function() {

	});
});

export default Router;
