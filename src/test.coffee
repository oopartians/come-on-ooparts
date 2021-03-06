express = require 'express'

module.exports = (global) ->
	{app} = global

	express.Router()

	.get '/aaa', (req,res) ->
		col = global.col("test")
		col.find({}).toArray (err,list) ->
			if err?
				res.status(500).send new InternalApiError("db error", err)
				return

			res.status(200).send list

	.post '/aaa', (req,res) ->
		col = global.col("test")

		col.save req.body, (err) ->
			if err?
				res.status(500).send new InternalApiError("db error", err)
				return

			res.status(200).send()

	.delete '/aaa', (req,res) ->
		col = global.col("test")

		col.drop (err) ->
			if err?
				res.status(500).send new InternalApiError("db error", err)
				return

			res.status(200).send()