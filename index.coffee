{RestServer} = require './rest_server'

rest_server = new RestServer
rest_server.listen Number(process.env.PORT || 5000)