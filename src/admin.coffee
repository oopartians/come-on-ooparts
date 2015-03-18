express = require 'express'
{ObjectID} = require 'mongodb'
async = require 'async'
admin_auth = require './some/admin_auth'

module.exports = (global) ->
	{app} = global

	router = express.Router()

	router.post '/register', (req,res) ->
		col = global.col("member")

		async.parallel [
			(next) ->
				if req.member?.admin
					next()
				else
					col.findOne {admin:true}, (err,doc) ->
						console.log("db error : #{JSON.stringify(err)} or you are not an admin")
						return next {error:"InternalError", readable_error:"db error : #{JSON.stringify(err)}"} if err?
						return next {error:"InvalidAdminAccess", readable_error:"not an admin member"} if doc?
						next()
		], (err) ->
			if err?
				res.status(400).send err
				return

			col.save req.body, (err,nr_saved) ->
				if err?
					console.log("db error : #{JSON.stringify(err)}")
					res.status(400).send {error:"InternalError", readable_error:"db error : #{JSON.stringify(err)}"}
					return

				if nr_saved == 0
					console.log("nr_saved == 0")
					res.status(400).send {error:"InternalError", readable_error:"nr_saved == 0"}
					return

				res.status(200).send()

	router.post '/nominate_mentor', admin_auth, (req,res) ->
		col = global.col("member")
		{mentor_id,mentee_id} = req.body

		async.parallel [
			(next) ->
				setter = {}
				setter["mentees.#{mentee_id}"] = true
				col.update {_id:ObjectID(mentor_id)}, {$set:setter}, (err,nr_updated) ->
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
				res.status(400).send {error:"InternalError", readable_error:"db error : #{JSON.stringify(err)}"}
				return

			res.status(200).send()

	router.post '/meeting', admin_auth, (req,res) ->
		meeting_col = global.col("meeting")

		meeting_col.save req.body, (err,nr_saved) ->
			if err?
				res.status(400).send {error:"InternalError", readable_error:"db error : #{JSON.stringify(err)}"}
				return

			if nr_saved == 0
				res.status(400).send {error:"InternalError", readable_error:"nr_saved == 0"}
				return

			res.status(200).send()