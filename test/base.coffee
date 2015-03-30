_ = require 'underscore'
chai = require 'chai'
chai.should()
{expect} = chai
request = require 'request'
async = require 'async'

REST_URL = "http://localhost:5000"

get_session_ = (auth,next) ->
	request.post {
		url : "#{REST_URL}/auth/session"
		body : auth
		json : true
	}, (err,res,body) ->
		return next err if err?
		return next body if res.statusCode != 200
		next null, body.session_token, body.you, body.first_connection, body.attend_compensation

get_session = (auth,next) ->
	get_session_ auth, (err,session_token,you,first_connection,attend_comp) ->
		expect(err).to.be.null
		expect(session_token).not.to.be.null
		expect(session_token).to.have.length(7)
		next session_token, you, first_connection, attend_comp


module.exports =
	REST_URL : REST_URL
	_ : _
	expect : expect
	request : request
	async : async
	
	get_session : get_session