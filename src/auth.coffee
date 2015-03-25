express = require 'express'
{ObjectID} = require 'mongodb'
async = require 'async'

session_token_possibles = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
random_string = (n,possibles) ->
	text = ''
	text += possibles.charAt(Math.floor(Math.random() * possibles.length)) for i in [0...n]
	text

to_utc_time = (T) ->
	new Date(T.getTime() + T.getTimezoneOffset() * 60 * 1000)

to_korea_time = (T_utc) ->
	new Date(T_utc.getTime() + 540 * 60 * 1000)

check_same_day = (A,B) ->
	A.getFullYear() == B.getFullYear() && A.getMonth() == B.getMonth() && A.getDate() == B.getDate()

check_same_day_in_korea = (A,B) ->
	A_kor = to_korea_time to_utc_time A
	B_kor = to_korea_time to_utc_time B
	check_same_day A_kor, B_kor

module.exports = (global) ->
	{app,sessions} = global

	express.Router()

	.post '/session', (req,res) ->
		{name,password} = req.body
		col = global.col("member")
		now = new Date

		async.waterfall [
			(next) ->
				col.findOne {name:name,password:password}, (err,member) ->
					if err?
						next new InternalApiError("db error", err)
						return

					unless member?
						next new ApiError("NoSuchMember", "no matching member")
						return

					next null, member

			(member,next) ->
				setter = last_attendance_date : now
				col.update {_id:member._id}, {$set:setter}, (err,nr_updated) ->
					if err?
						next new InternalApiError("db error", err) if err?
						return

					if nr_updated == 0
						next new InternalApiError("nr_updated == 0")
						return

					next null, member

		], (err,member) ->
			return res.status(400).send err if err?

			loop
				session_token = random_string 7, session_token_possibles
				break if not sessions[session_token]?
			sessions[session_token] = member

			if member.last_attendance_date?
				first_connection = not check_same_day_in_korea(member.last_attendance_date, now)
			else
				first_connection = true

			res.status(200).send
				session_token : session_token
				you : ReturnMember(member)
				first_connection : first_connection

	.put '/change_password', (req,res) ->
		{member} = req
		unless member?
			res.status(400).send new ApiError("UnauthorizedMember")
			return

		{new_password} = req.body
		col = global.col("member")

		col.update {_id:member._id}, {$set:{password:new_password}}, (err,member) ->
			if err?
				res.status(400).send new InternalApiError("db error", err)
				return

			unless member?
				res.status(400).send new ApiError("NoSuchMember", "no such member")
				return

			res.status(200).send()

	.delete '/unregister', (req,res) ->
		{member} = req
		unless member?
			res.status(400).send new ApiError("UnauthorizedMember")
			return

		col = global.col("member")

		col.remove {_id:member._id}, {single:true}, (err,nr_removed) ->
			if err?
				res.status(400).send new InternalApiError("db error", err)
				return

			if nr_removed == 0
				res.status(400).send new InternalApiError("nr_removed == 0")
				return

			res.status(200).send()