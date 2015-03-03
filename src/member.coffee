express = require 'express'
ObjectID = require 'mongodb'

module.exports = (global) ->
	{app} = global

	router = express.Router()

	router.get '/list', (req,res) ->
		col = global.col("member")
		col.find({}).toArray (err,list) ->
			if err?
				res.status(403).send {error:"InternalError", readable_error:"db error : #{JSON.stringify(err)}"}
				return

			res.status(200).send list

	router.get '/:member_id', (req,res) ->
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

	router.delete '/:member_id', (req,res) ->
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