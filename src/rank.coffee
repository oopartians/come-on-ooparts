express = require 'express'
{ObjectID} = require 'mongodb'
admin_auth = require './some/admin_auth'
_ = require 'underscore'

{get_yesterday} = require './some/days'

DEFAULT_LENGTH = 10

module.exports = (global) ->
	{app} = global

	express.Router()

	.get '/neigong', (req,res) ->
		col = global.col("member")
		col.find().sort({"items.neigong.balance":-1}).limit(10).toArray (err,docs) ->
			if err?
				res.status(403).send new InternalApiError("db error", err)
				return

			res.status(200).send docs.map ReturnMember

	.get '/cs_attendance', (req,res) ->
		col = global.col("member")
		now = new Date
		valid_lower_limit_time = get_yesterday(now).getTime()
		col.find({last_attendance_date_time:{$gt:valid_lower_limit_time}}).sort({"cs_attendance":-1}).limit(10).toArray (err,docs) ->
			if err?
				res.status(403).send new InternalApiError("db error", err)
				return

			res.status(200).send docs.map ReturnMember