express = require 'express'
{ObjectID} = require 'mongodb'

module.exports = (global) ->
	{app} = global

	router = express.Router()

	router.get '/today', (req,res) ->
		col = global.col("notice")
		col.find().sort({$natural:-1}).limit(1).toArray (err,docs) ->
			if err?
				res.status(403).send {error:"InternalError", readable_error:"db error : #{JSON.stringify(err)}"}
				return

			[doc] = docs
			doc ?= {word:null}

			res.status(200).send doc


	router.put '/word', (req,res) ->
		{word} = req.body

		col = global.col("notice")
		col.save {word:word}, (err) ->
			if err?
				res.status(403).send {error:"InternalError", readable_error:"db error : #{JSON.stringify(err)}"}
				return

			res.status(200).send()