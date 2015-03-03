express = require 'express'
ObjectID = require 'mongodb'
async = require 'async'

module.exports = (global) ->
	{app} = global

	router = express.Router()

	router.post '/register', (req,res) ->
		col = global.col("member")
		col.save(req.body) (err,nr_saved) ->
			if err?
				res.status(403).send {error:"InternalError", readable_error:"db error : #{JSON.stringify(err)}"}
				return

			if nr_saved == 0
				res.status(403).send {error:"InternalError", readable_error:"nr_saved == 0"}
				return

			res.status(200).send()

	router.post '/nominate_mentor', (req,res) ->
		col = global.col("member")
		{mentor_id,mentee_id} = req.body

		async.parallel [
			(next) ->
				col.update {_id:ObjectID(mentor_id)}, {$set:{"mentees.#{mentee_id}":true}, (err,nr_updated) ->
					return next err if err?
					return next "nr_updated == 0" if nr_updated == 0
					next()
			(next) ->
				col.update {_id:ObjectID(mentee_id)}, {$set:{"mentor":ObjectID(mentor_id)}}, (err,nr_updated) ->
					return next err if err?
					return next "nr_updated == 0" if nr_updated == 0
					next()
		], (err) ->
			if err?
				res.status(403).send {error:"InternalError", readable_error:"db error : #{JSON.stringify(err)}"}
				return

			res.status(200).send()

	router.post '/meeting', (req,res) ->
		meeting_col = global.col("meeting")

		meeting_col.save req.body, (err,nr_saved) ->
			if err?
				res.status(403).send {error:"InternalError", readable_error:"db error : #{JSON.stringify(err)}"}
				return

			if nr_saved == 0
				res.status(403).send {error:"InternalError", readable_error:"nr_saved == 0"}
				return

			res.status(200).send()