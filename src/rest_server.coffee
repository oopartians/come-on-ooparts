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