express = require 'express'
{ObjectID} = require 'mongodb'
admin_auth = require './some/admin_auth'
_ = require 'underscore'

DEFAULT_LENGTH = 10

module.exports = (global) ->
	{app} = global

	ApiFor = (sortkey) ->
		(req,res) ->
			col = global.col("member")
			col.find().sort(sortkey).limit(10).toArray (err,docs) ->
				if err?
					res.status(403).send new InternalApiError("db error", err)
					return

				res.status(200).send docs.map ReturnMember
		

	express.Router()

	.get '/neigong', ApiFor {"items.neigong.balance":-1}
			
	.get '/cs_attendance', ApiFor {"items.cs_attendance.balance":-1}