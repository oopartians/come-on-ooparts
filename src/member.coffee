express = require 'express'
{ObjectID} = require 'mongodb'
_ = require 'underscore'
admin_auth = require './some/admin_auth'

module.exports = (global) ->
	{app} = global

	router = express.Router()

	router.get '/list', (req,res) ->
		col = global.col("member")
		col.find({}).toArray (err,list) ->
			if err?
				res.status(403).send new InternalApiError("db error", err)
				return

			list = list.map (member)->
				_(member).omit 'password'

			res.status(200).send list

	router.get '/:member_id', (req,res) ->
		col = global.col("member")
		{member_id} = req.params

		col.findOne {_id:ObjectID(member_id)}, (err,member) ->
			if err?
				res.status(403).send new InternalApiError("db error", err)
				return

			unless member?
				res.status(403).send new ApiError("NoSuchMember", "no such member")
				return

			res.status(200).send _(member).omit 'password'

	router.delete '/:member_id', admin_auth, (req,res) ->
		col = global.col("member")
		{member_id} = req.params

		col.remove {_id:ObjectID(member_id)}, {single:true}, (err,member) ->
			if err?
				res.status(403).send new InternalApiError("db error", err)
				return

			unless member?
				res.status(403).send new ApiError("NoSuchMember", "no such member")
				return

			res.status(200).send()