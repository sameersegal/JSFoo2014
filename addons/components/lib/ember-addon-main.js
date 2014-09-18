'use strict';

var path = require('path');
var fs   = require('fs');

function App(project) {
  this.project = project;
  this.name    = 'JSFoo Components';
}

function unwatchedTree(dir) {
  return {
    read:    function() { return dir; },
    cleanup: function() { }
  };
}

App.prototype.treeFor = function treeFor(name) {
  // console.log("treeFor:" + name);
  // console.log("treeFor:" + this.root);

  if(name === "app") {
    // send files
    var treePath =  path.join(this.root, "../", "app");
    console.log(treePath);
    return unwatchedTree(treePath);
  } else if(name === "addon") {
    // add on files that I want to send
  } else if(name === "vendor") {
    // bower deps
  }
};

App.prototype.included = function included(app) {
  this.app = app;
};

module.exports = App;