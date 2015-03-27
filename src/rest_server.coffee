express = require 'express'
bodyParser = require 'body-parser'
db = require './db'

require './global/api_error'
require './global/return_member'

log_error = (err,req,res,next) ->
	console.error String(err)
	console.error err.stack
	next err

api_error_handler = (err,req,res,next) ->
	unless err?
		next()
		return

	if err.class == 'ApiError'
		res.status(err.statuscode).send err
	else
		next err

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

		@app.get "/crossdomain.xml", ( req, res ) ->
			xml = '<?xml version="1.0"?>\n<!DOCTYPE cross-domain-policy SYSTEM' +
			' "http://www.adobe.com/xml/dtds/cross-domain-policy.dtd">\n<cross-domain-policy>\n'
			xml += '<allow-access-from domain="*" to-ports="*"/>\n'
			xml += '<allow-http-request-headers-from domain="*" headers="*"/>\n'
			xml += '</cross-domain-policy>\n'
			
			req.setEncoding 'utf8'
			res.writeHead 200, {'Content-Type': 'text/xml'}
			res.end xml
			#res.status(200).send xml

		global =
			app : @app
			sessions : {}

		db global
		@app.use (require './auth-middleware') global
		@app.use (require './method-override-middleware')
		@app.use '/auth', (require './auth') global
		@app.use '/test', (require './test') global
		@app.use '/member', (require './member') global
		@app.use '/admin', (require './admin') global
		@app.use '/notice', (require './notice') global
		@app.use '/rank', (require './rank') global
		@app.use '/files', (require './files') global
		@app.use log_error
		@app.use api_error_handler
		return


	listen : ->
		@sv.listen arguments...


module.exports =
	RestServer : RestServer