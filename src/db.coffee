MongoClient = require('mongodb').MongoClient
events = require 'events'
{MONGOHQ_URL} = process.env

module.exports = (global) ->
	cached_db = {}
	cached_col = {}

	do try_ = ->
		MongoClient.connect MONGOHQ_URL, (err,db) ->
			if err
				console.error "mongo connect failed : ", err, MONGOHQ_URL
				setTimeout try_, 3000
				return
			cached_db['default'] = db

	make_col = (path) ->
		[dbname,colname] = path.split('/')
		unless colname?
			colname = dbname
			dbname = 'default'

		db = cached_db[dbname]
		unless db?
			return null

		db.collection(colname)

	global.col = (path) ->
		col = cached_col[path]

		unless col?
			col = cached_col[path] = make_col(path)

		col