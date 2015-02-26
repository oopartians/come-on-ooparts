express = require 'express'

class RestServer

	constructor : ->
		@app = express()
		@sv = (require 'http').Server @app

		@app.use express.query()

		@app.get '/ping', (req,res) ->
			res.status(200).send "pong"

	listen : ->
		@sv.listen arguments...


module.exports =
	RestServer : RestServer