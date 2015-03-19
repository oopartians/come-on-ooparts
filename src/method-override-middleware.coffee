module.exports = (req, res, next)->
	key = "_method"
	req.originalMethod = req.originalMethod or req.method

	#req.body
	if req.body and typeof req.body is 'object' and key in req.body
		method = req.body[key].toLowerCase()
		delete req.body[key]
	
	#check X-HTTP-Method-Override
	if req.headers['x-http-method-override']
		method = req.headers['x-http-method-override'].toLowerCase()

	
	req.method = method.toUpperCase() if method?
	next()