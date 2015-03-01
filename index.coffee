{RestServer} = require './src/rest_server'

rest_server = new RestServer

{PORT} = process.env
PORT ?= 5000
rest_server.listen Number(PORT), ->
	console.log "The server listening port #{PORT}..."