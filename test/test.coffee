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
		next null, body.session_token

get_session = (auth,next) ->
	get_session_ auth, (err,session_token) ->
		expect(err).to.be.null
		expect(session_token).not.to.be.null
		expect(session_token).to.have.length(7)
		next session_token

describe '#rest', ->

	before (next) ->
		gildong_profile = require './gildong.json'

		request.post {
			url : "#{REST_URL}/admin/register"
			body : gildong_profile
			json : true
		}, (err,res,body) ->
			expect(err).to.be.null
			expect(res.statusCode).to.equal(200)
			next()

	it 'should ok to get session', (next) ->
		get_session (require './gildong-auth.json'), (session_token) ->
			next()

	it 'should ok to change password', (next) ->
		gildong_auth = (require './gildong-auth.json')

		lets_change_password = (to,session_token,next) ->
			request.put {
				url : "#{REST_URL}/auth/change_password?session_token=#{session_token}"
				body : {new_password:to}
				json : true
			}, (err,res,body) ->
				expect(err).to.be.null
				expect(res.statusCode).to.equal(200)
				next()

		oldone = gildong_auth.password
		newone = "123987"

		async.series [
			(next) ->
				get_session gildong_auth, (session_token) ->
					lets_change_password newone, session_token, ->
						gildong_auth.password = newone
						next()
				
			(next) ->
				get_session gildong_auth, (session_token) ->
					gildong_auth.password = oldone
					lets_change_password oldone, session_token, next
				
		], next

	after (next) ->
		get_session (require './gildong-auth.json'), (session_token) ->
			request.del {
				url : "#{REST_URL}/auth/unregister?session_token=#{session_token}"
			}, (err,res,body) ->
				expect(err).to.be.null
				expect(res.statusCode).to.equal(200)
				next()