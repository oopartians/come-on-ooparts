express = require 'express'
ObjectID = require 'mongodb'

session_token_possibles = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
random_string = (n,possibles) ->
	text = ''
	text += possibles.charAt(Math.floor(Math.random() * possibles.length)) for i in [0...n]
	text


module.exports = (global) ->
	{app,sessions} = global

	router = express.Router()

	router.post '/session', (req,res) ->
		{name,password} = req.body
		col = global.col("member")
		col.findOne {name:name,password:password}, (err,doc) ->
			if err?
				res.status(403).send {error:"InternalError", readable_error:"db error : #{JSON.stringify(err)}"}
				return

			unless doc?
				res.status(403).send {error:"NoSuchMember", readable_error:"no matching member"}
				return

			do
				session_token = random_string 7, session_token_possibles
			until not sessions[session_token]?
			sessions[session_token] = doc

			res.status(200).send session_token:session_token

	auth = (req,res,next) ->
		{session_token} = req.params
		if session_token?
			member_info = sessions[session_token]
			unless member_info?
				return next "NoSuchSession"
			req.member = member_info

		next()

	router.post '/change_password', auth, (req,res) ->
		{member} = req.params
		unless member?
			res.status(403).send {error:"UnauthorizedMember"}
		{current_password,new_password} = req.body
		col = global.col("member")


		col.findOne {_id:ObjectID(member_id)}, (err,member) ->
			if err?
				res.status(403).send {error:"InternalError", readable_error:"db error : #{JSON.stringify(err)}"}
				return

			unless member?
				res.status(403).send {error:"NoSuchMember", readable_error:"no such member"}
				return

			res.status(200).send()

	router.post '/report_attendance', (req,res) ->
		col = global.col("test")
		{member_id} = req.params

		col.remove {_id:ObjectID(member_id)}, {single:true}, (err,member) ->
			if err?
				res.status(403).send {error:"InternalError", readable_error:"db error : #{JSON.stringify(err)}"}
				return

			unless member?
				res.status(403).send {error:"NoSuchMember", readable_error:"no such member"}
				return

			res.status(200).send()