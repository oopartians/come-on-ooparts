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

				Q = {_id:member._id}
				set =
					last_attendance_date : now
					last_attendance_date_time : now.getTime()
				inc = {}

				unless member.last_attendance_date?
					first_connection = true
					set.cs_attendance = 1
				else
					is_same_day = check_same_day(member.last_attendance_date, now)
					is_yesterday = check_yesterday(member.last_attendance_date, now)
					first_connection = not is_same_day
					if is_yesterday
						# consecutive
						inc.cs_attendance = 1
					else if not is_same_day
						# reset cs_attendance
						set.cs_attendance = 1
					# for atomic
					Q.last_attendance_date_time = member.last_attendance_date_time

				U = $set : set
				if Object.keys(inc).length > 0
					U.$inc = inc

				# 연속 출석이다.
				col.update Q, U, (err,nr_updated) ->
					if err?
						next new InternalApiError("db error", err) if err?
						return

					if nr_updated == 0
						next new InternalApiError("nr_updated == 0")
						return

					next()

		], (err) ->
			return res.status(403).send err if err?

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
			res.status(401).send new ApiError("UnauthorizedMember")
			return

		{new_password} = req.body
		col = global.col("member")

		col.update {_id:member._id}, {$set:{password:new_password}}, (err,nr_updated) ->
			if err?
				res.status(500).send new InternalApiError("db error", err)
				return

			if nr_updated == 0
				res.status(500).send new InternalApiError("nr_updated == 0")
				return

			res.status(200).send()

	.delete '/unregister', (req,res) ->
		{member} = req
		unless member?
			res.status(401).send new ApiError("UnauthorizedMember")
			return

		col = global.col("member")

		col.remove {_id:member._id}, {single:true}, (err,nr_removed) ->
			if err?
				res.status(500).send new InternalApiError("db error", err)
				return

			if nr_removed == 0
				res.status(500).send new InternalApiError("nr_removed == 0")
				return

			res.status(200).send()

	.put '/change_profile_url', (req,res) ->
		{member} = req
		{new_profile_url} = req.body

		col = global.col("member")
		col.update {_id:member._id}, {$set:{profile_url:new_profile_url}}, (err,nr_updated) ->
			if err?
				res.status(500).send new InternalApiError("db error", err)
				return

			if nr_updated == 0
				res.status(500).send new InternalApiError("nr_updated == 0")
				return

			res.status(200).send()	