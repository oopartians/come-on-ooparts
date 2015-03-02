express = require 'express'
ObjectID = require 'mongodb'

module.exports = (global) ->
	{app} = global

	router = express.Router()

	router.post '/register', (req,res) ->
		col = global.col("member")
		col.count {}, (err,nr_docs) ->
			if err?
				res.status(403).send {error:"InternalError", readable_error:"db error : #{JSON.stringify(err)}"}
				return

			console.log "nr_docs : #{nr_docs}"
			res.status(200).send()
			return

			col.save req.body, (err,nr_saved) ->
				if err?
					res.status(403).send {error:"InternalError", readable_error:"db error : #{JSON.stringify(err)}"}
					return

				if nr_saved == 0
					res.status(403).send {error:"InternalError", readable_error:"nr_saved == 0"}
					return

				res.status(200).send()

	router.post '/nominate_mentor', (req,res) ->
		col = global.col("test")
		{member_id} = req.params

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