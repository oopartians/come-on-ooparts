express = require 'express'

module.exports = (global) ->
	{app} = global

	router = express.Router()

	router.get '/aaa', (req,res) ->
		col = global.col("test")
		col.find({}).toArray (err,list) ->
			if err?
				res.status(403).send new InternalApiError("db error", err)
				return

			res.status(200).send list

	router.post '/aaa', (req,res) ->
		col = global.col("test")

		col.save req.body, (err,nr_saved) ->
			if err?
				res.status(403).send new InternalApiError("db error", err)
				return

			if nr_saved == 0
				res.status(403).send new InternalApiError("nr_saved == 0")
				return

			res.status(200).send()

	router.delete '/aaa', (req,res) ->
		col = global.col("test")

		col.drop (err) ->
			if err?
				res.status(403).send new InternalApiError("db error", err)
				return

			res.status(200).send()