express = require 'express'
{ObjectID} = require 'mongodb'
admin_auth = require './some/admin_auth'

module.exports = (global) ->
	{app} = global

	express.Router()

	.get '/today', (req,res) ->
		col = global.col("notice")
		col.find().sort({$natural:-1}).limit(1).toArray (err,docs) ->
			if err?
				res.status(500).send new InternalApiError("db error", err)
				return

			[doc] = docs
			doc ?= {word:null}
			res.status(200).send doc
			
	.put '/word', admin_auth, (req,res) ->
		{word} = req.body

		col = global.col("notice")
		col.save {word:word}, (err) ->
			if err?
				res.status(500).send new InternalApiError("db error", err)
				return

			res.status(200).send()