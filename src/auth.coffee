express = require 'express'
{ObjectID} = require 'mongodb'

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
				res.status(400).send {error:"InternalError", readable_error:"db error : #{JSON.stringify(err)}"}
				return

			unless doc?
				res.status(400).send {error:"NoSuchMember", readable_error:"no matching member"}
				return

			loop
				session_token = random_string 7, session_token_possibles
				break if not sessions[session_token]?
			sessions[session_token] = doc

			res.status(200).send session_token:session_token

	router.post '/change_password', (req,res) ->
		{member} = req
		unless member?
			res.status(400).send {error:"UnauthorizedMember"}
			return

		{new_password} = req.body
		col = global.col("member")

		col.update {_id:ObjectID(member_id)}, {$set:{password:new_password}}, (err,member) ->
			if err?
				res.status(400).send {error:"InternalError", readable_error:"db error : #{JSON.stringify(err)}"}
				return

			unless member?
				res.status(400).send {error:"NoSuchMember", readable_error:"no such member"}
				return

			res.status(200).send()