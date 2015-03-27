express = require 'express'
{ObjectID} = require 'mongodb'
cookieParser = require 'cookie-parser'
async = require 'async'

admin_auth = require './some/admin_auth'

module.exports = (global) ->
	{app} = global

	AccessTabom = (n) ->
		(req,res) ->
			# res.cookie("hello", "world")
			# res.cookie("nice", {to:"meet you!"})
			console.log("Cookies: ", req.cookies)

			async.series [
				(next) ->
					unless req.cookies.session_token
						next "NoToken"
					else
						next()

				(next) ->
					{session_token} = req.cookies
					member_info = global.sessions[session_token]
					unless member_info?
						next "InvalidToken"
					else
						next()

			], (err) ->

				if err?
					# relogin
					res.render 'login'
				else
					res.status(200).send()

	express.Router()

	.use cookieParser()

	.post '/token', (req,res) ->
		unless req.member?
			res.status(401).send new ApiError("UnauthorizedError")
			return

		col = global.col("tabom")
		col.save {owner:req.member._id}, (err,doc) ->
			if err?
				res.status(500).send new InternalApiError("db error", err)
				return

			res.status(200).send {token:doc._id}
			
	.get '/one', AccessTabom 1
	.get '/two', AccessTabom 2
	.get '/three', AccessTabom 3
