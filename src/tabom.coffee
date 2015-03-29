express = require 'express'
{ObjectID} = require 'mongodb'
async = require 'async'

admin_auth = require './some/admin_auth'

get_tabom_img = (n) ->
	if n <= 10
		"reco_#{n}.png"
	else if n < 15
		"reco_10_plus.png"
	else if n < 20
		"reco_15_plus.png"
	else if n < 25
		"reco_20_plus.png"
	else
		"reco_25_plus.png"


module.exports = (global) ->
	{app} = global

	AccessTabom = (n) ->
		(req,res) ->
			{token} = req.params

			unless req.member?
				# relogin
				res.render 'login', redirect_url : req.originalUrl
				return

			col = global.col("tabom")
			col.findOne {_id:ObjectID(token)}, (err,doc) ->
				if err?
					res.status(500).send new InternalApiError("db error", err)
					return

				unless doc?
					res.status(403).send new ApiError("NoSuchTabomToken")
					return

				if doc.people?[String(req.member._id)]?
					res.render "instant_msg", msg : "이미 추천하였습니다."
					return

				Q = {}
				Q._id = ObjectID(token)
				Q["people.#{req.member._id}"] = $exists : false
				setter = {}
				setter["people.#{req.member._id}"] = n
				inc = nr_recommended : 1
				U = $set:setter, $inc : inc
				col.update Q, U, (err,nr_updated) ->
					if err?
						res.status(500).send new InternalApiError("db error", err)
						return

					if nr_updated == 0
						res.status(500).send new InternalApiError("nr_updated == 0")
						return

					res.render "instant_msg", msg : "추천하였습니다."

	ShowImage = (req,res) ->
		{token} = req.params
		col = global.col("tabom")
		col.findOne {_id:ObjectID(token)}, (err,doc) ->
			if err? or (not doc?)
				res.setHeader 'Location', "/img/reco_not_found.png"
				res.send 302
				return

			{nr_recommended} = doc
			nr_recommended ?= 0
			res.setHeader 'Location', "/img/#{get_tabom_img(nr_recommended)}"
			res.send 302


	express.Router()

	.post '/token', (req,res) ->
		unless req.member?
			res.status(401).send new ApiError("UnauthorizedError")
			return

		now = new Date

		col = global.col("tabom")
		col.save {owner:req.member._id, date:now, date_time:now.getTime()}, (err,doc) ->
			if err?
				res.status(500).send new InternalApiError("db error", err)
				return

			res.status(200).send {token:doc._id}
			
	.get '/recommend/:token', AccessTabom 1

	.get '/recommend/:token/status/image', ShowImage