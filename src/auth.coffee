express = require 'express'
{ObjectID} = require 'mongodb'
async = require 'async'

{check_same_day,check_yesterday} = require './some/days'

session_token_possibles = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
random_string = (n,possibles) ->
	text = ''
	text += possibles.charAt(Math.floor(Math.random() * possibles.length)) for i in [0...n]
	text


module.exports = (global) ->
	{app,sessions} = global

	express.Router()

	.post '/session', (req,res) ->
		{name,password} = req.body
		col = global.col("member")
		now = new Date
		member = null
		first_connection = null

		async.waterfall [
			(next) ->
				col.findOne {name:name,password:password}, (err,_member) ->
					if err?
						next new InternalApiError("db error", err)
						return

					unless _member?
						next new ApiError("NoSuchMember", "no matching member")
						return

					member = _member

					next()

			(next) ->
				setter =
					last_attendance_date : now
					last_attendance_date_time : now.getTime()
				col.update {_id:member._id}, {$set:setter}, (err,nr_updated) ->
					if err?
						next new InternalApiError("db error", err) if err?
						return

					if nr_updated == 0
						next new InternalApiError("nr_updated == 0")
						return

					next()

			(next) ->

				Q = {_id:member._id}

				unless member.last_attendance_date?
					first_connection = true
					inc_cs_attendance = true
				else
					is_same_day = check_same_day(member.last_attendance_date, now)
					is_yesterday = check_yesterday(member.last_attendance_date, now)
					first_connection = not is_same_day
					inc_cs_attendance = is_yesterday
					# for atomic
					Q.last_attendance_date_time = member.last_attendance_date_time

				console.log "inc_cs_attendance : ", inc_cs_attendance

				if not inc_cs_attendance
					next()
					return

				# 연속 출석이다.
				col.update Q, {$inc:{cs_attendance:1}}, (err,nr_updated) ->
					if err?
						next new InternalApiError("db error", err) if err?
						return

					if nr_updated == 0
						next new InternalApiError("nr_updated == 0")
						return

					next()

		], (err) ->
			return res.status(400).send err if err?

			loop
				session_token = random_string 7, session_token_possibles
				break if not sessions[session_token]?
			sessions[session_token] = member


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