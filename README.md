JSFoo2014
=========

Demo for JSFoo 2014, Bangalore using Ember.js, CouchDB, CouchDB-Lucene and Twitter's TypeAhead

Setup
-----
1. Node
2. CouchDB
3. CouchDB Lucene


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

We use the adapter & serializers to fix the embedded payload into something that Ember likes.

## Components

Twitter's Typeahead

