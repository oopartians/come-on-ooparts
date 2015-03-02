express = require 'express'
bodyParser = require 'body-parser'
db = require './db'

class RestServer

	constructor : ->
		@app = express()
		@sv = (require 'http').Server @app

		@app.use express.query()
		@app.use bodyParser.json()

		@app.get '/ping', (req,res) ->
			res.status(200).send "pong"

		@app.get '/ping2', (req,res) ->
			res.status(200).send {session:'1234567890a'}

		@app.get '/ping3', (req,res) ->
			res.status(200).send [{name:'egg', period_number:5},{name:'sbg', period_number:4}]

		global =
			app : @app

		db global
		@app.use '/test', (require './test') global
		@app.use '/member', (require './member') global
		return


	listen : ->
		@sv.listen arguments...


module.exports =
	RestServer : RestServer