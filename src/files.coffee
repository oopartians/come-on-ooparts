express = require 'express'
mongo = require 'mongodb'
{ObjectID} = mongo
_ = require 'underscore'
admin_auth = require './some/admin_auth'
Grid = require 'gridfs-stream'

ROOT_COL = "files"

module.exports = (global) ->
	{app} = global

	member_auth = (req,res,next) ->
		unless req.member?
			next (new ApiError("UnauthorizedMember")).status(401)
		else
			next()

	fetch_gfs = (req,res,next) ->
		db = global.db()
		unless db?
			next (new InternalApiError("not ready")).status(500)
			return
		req.gfs = Grid(db, mongo)
		next()


	express.Router()

	.post '/upload', member_auth, fetch_gfs, (req,res) ->
		{gfs} = req

		w = gfs.createWriteStream
			root : ROOT_COL

		req.pipe(w)

		w.once 'close', (file) ->
			col = global.col("member")
			col.update {_id:req.member._id}, {$push:{files:file._id}}, (err,nr_updated) ->
				if err?
					res.status(500).send new InternalApiError("db error", err)
					return

				if nr_updated == 0
					res.status(500).send new InternalApiError("nr_updated == 0")
					return

				res.status(200).send {id:file._id}

		w.once 'error', (err) ->
			res.status(500).send new InternalApiError("GridFS write failed", String(err))


	.get '/:id', fetch_gfs, (req,res) ->
		{gfs} = req
		{id} = req.params

		r = gfs.createReadStream
			root : ROOT_COL
			_id : ObjectID(id)

		r.once 'error', (err) ->
			res.status(500).send new InternalApiError("GridFS read failed", String(err))

		r.pipe(res)