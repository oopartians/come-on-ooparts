express = require 'express'
{ObjectID} = require 'mongodb'
async = require 'async'
admin_auth = require './some/admin_auth'

module.exports = (global) ->
	{app} = global

	express.Router()

	.post '/register', (req,res) ->
		col = global.col("member")

		async.parallel [
			(next) ->
				if req.member?.admin
					next()
				else
					col.findOne {admin:true}, (err,doc) ->
						return next new InternalApiError("db error", err) if err?
						return next new ApiError("InvalidAdminAccess", "not an admin member! not even a first registration") if doc?
						next()
		], (err) ->
			if err?
				res.status(403).send err
				return

			col.save req.body, (err) ->
				if err?
					res.status(500).send new InternalApiError("db error", err)
					return

				res.status(200).send()

	.post '/nominate_mentor', admin_auth, (req,res) ->
		col = global.col("member")
		{mentor_id,mentee_id} = req.body

		async.parallel [
			(next) ->
				setter = {}
				setter["mentees.#{mentee_id}"] = true
				col.update {_id:ObjectID(mentor_id)}, {$set:setter}, (err,nr_updated) ->
					return next new InternalApiError("db error", err) if err?
					return next new InternalApiError("nr_updated == 0") if nr_updated == 0
					next()
			(next) ->
				col.update {_id:ObjectID(mentee_id)}, {$set:{"mentor":ObjectID(mentor_id)}}, (err,nr_updated) ->
					return next new InternalApiError("db error", err) if err?
					return next new InternalApiError("nr_updated == 0") if nr_updated == 0
					next()
		], (apierror) ->
			if apierror?
				res.status(403).send apierror
				return

			res.status(200).send()

	.post '/meeting', admin_auth, (req,res) ->
		meeting_col = global.col("meeting")

		meeting_col.save req.body, (err) ->
			if err?
				res.status(500).send new InternalApiError("db error", err)
				return

			res.status(200).send()