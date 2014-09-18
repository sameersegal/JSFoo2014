## Intro

### Slide 0

* I am KB, worked on Ember even before it hit beta

### Slide 1 & 2

* Everyone says Ember is meant for really ambitious applications but how do you do it?
* There is the ToDo list example
* Then there is the Discourse, Zendesk and Vimeo
* What about a more human intermediate example?

### Slide 3

* Sneek peak
* Going to build our very own 9gag

### Slide 4

* An ambitious app has the following elements:
	* Data
	* Custom Views
	* Testing
	* Modules

## App

```
.
|-- LICENSE
|-- README.md
|-- addons
|   |-- adapters
|   |-- components
|   `-- utils
|-- app
|   |-- Brocfile.js
|   |-- README.md
|   |-- app
|   |-- bower.json
|   |-- bower_components
|   |-- config
|   |-- dist
|   |-- node_modules
|   |-- package.json
|   |-- public
|   |-- testem.json
|   |-- tests
|   |-- tmp
|   `-- vendor
`-- data
    |-- README.md
    |-- index.coffee
    |-- node_modules
    `-- package.json

16 directories, 10 files

```

Ember-CLI the coolest thing after Ember, Ember-Data, Ember-Runtime, Ember-Metal to happen to Ember!

```
npm install -g ember-cli
```

### App

```
ember server
```

### Add Ons

The most amazing part of the ember-cli is the modules. Split your app into multiple Modules. Reduces build time.

```
ember addon components
ember addon adapters
```

## Data
9gag APIs - fetch 10 records and move them into CouchDB

## CouchDB && Lucene

```
brew install couchdb

git clone git@github.com:rnewson/couchdb-lucene.git
cd couchdb-lucene
mvn
ls target/couchdb-lucene-1.0.0-SNAPSHOT-dist.tar.gz
tar -xvzf couchdb-lucene-1.0.0-SNAPSHOT-dist.tar.gz
cd couchdb-lucene-1.0.0-SNAPSHOT
./bin/run &
```

vi /etc/couchdb/local.ini or /usr/etc/couchdb/local.ini
```
[httpd_global_handlers]
_fti = {couch_httpd_proxy, handle_proxy_req, <<"http://127.0.0.1:5985">>}
```

If you are using a Mac and have installed via brew
```
$ launchctl unload ~/Library/LaunchAgents/homebrew.mxcl.couchdb.plist
$ launchctl load ~/Library/LaunchAgents/homebrew.mxcl.couchdb.plist
```


```
function(doc) { 
	var ret = new Document(); 
	ret.add(doc.caption,{\"store\":\"yes\"}); 
	return ret;
}
```

Full Design Document:
```
{
   "_id": "_design/list",
   "language": "javascript",
   "views": {
       "byVotes": {
           "map": "function(doc) {\n  emit(doc.votes.count, {caption: doc.caption, images: doc.images[0].link});\n}"
       }
   },
   "fulltext": {
       "byCaption": {
           "index": "function(doc) { var ret = new Document(); ret.add(doc.caption,{\"store\":\"yes\"}); return ret;}"
       }
   }
}
```

Query: http://127.0.0.1:5984/_fti/local/jsfoo/_design/list/byCaption?q=gu*


```
{
  "q": "default:gu*",
  "fetch_duration": 1,
  "total_rows": 5,
  "limit": 25,
  "search_duration": 40,
  "etag": "a275ecdb012",
  "skip": 0,
  "rows": [
    {
      "score": 1,
      "id": "avZr9DE",
      "fields": {
        "default": "Good guy Baptist minister"
      }
    },
    {
      "score": 1,
      "id": "azLr4qN",
      "fields": {
        "default": "Foreplay is important guys"
      }
    },
    {
      "score": 1,
      "id": "a0Pdnwz",
      "fields": {
        "default": "To the guy who posted that he lost 15 Kg in two weeks, go see a doctor"
      }
    },
    {
      "score": 1,
      "id": "a8bpVzY",
      "fields": {
        "default": "Bumped into a guy, causing him to spill his coffee at Tm Horton's. He apologized for getting my shoes wet."
      }
    },
    {
      "score": 1,
      "id": "a49ZArA",
      "fields": {
        "default": "My pet will never win a Nobel Prize... guess why"
      }
    }
  ]
}
```

## Adapters

The thing about Ember is ... don't fight it. The more you fight it, the more pain you will feel.

What we are using?

```
{
   "_id": "a0Pdnwz",
   "_rev": "1-87cc0c5666b71ce200e34a1e98aa99b2",
   "caption": "To the guy who posted that he lost 15 Kg in two weeks, go see a doctor",
   "images": [
       {
           "type": "normal",
           "link": "http://img-9gag-lol.9cache.com/photo/a0Pdnwz_460s_v1.jpg"
       },
       {
           "type": "large",
           "link": "http://img-9gag-lol.9cache.com/photo/a0Pdnwz_700b_v1.jpg"
       }
   ],
   "link": "http://9gag.com/gag/a0Pdnwz",
   "votes": {
       "count": 2328
   }
}
```

What ember wants to see?

```
{
   post: {
	   "id": "a0Pdnwz",
	   "_rev": "1-87cc0c5666b71ce200e34a1e98aa99b2",
	   "caption": "To the guy who posted that he lost 15 Kg in two weeks, go see a doctor",
	   "images": [
	   		100,
	   		101
	   ],
	   "link": "http://9gag.com/gag/a0Pdnwz",
	   "votes": 500
	},
	"images": [
	       {
	       	   "id": 100,
	           "type": "normal",
	           "link": "http://img-9gag-lol.9cache.com/photo/a0Pdnwz_460s_v1.jpg"
	       },
	       {
	       	   "id": 101,	       
	           "type": "large",
	           "link": "http://img-9gag-lol.9cache.com/photo/a0Pdnwz_700b_v1.jpg"
	       }
	   ],
	"votes": {
		"id": 500,
		"count": 2328
	}
}
```

So we use the adapter & serializers to fix the embedded payload into something that Ember likes.

## Components

Twitter's Typeahead

## Testing

Unit Testing is your best friend. Plain, simple and super fast.