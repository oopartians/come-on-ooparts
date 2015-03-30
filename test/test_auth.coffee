{_,expect,request,async,REST_URL,get_session} = require './base'

exrules = require '../conf/exchange_rules.json'

get_diff_items = (cur,prev) ->
	all_keys = _.union Object.keys(cur), Object.keys(prev)
	ret = {}

	for key in all_keys
		a = cur[key]
		a ?= 0
		b = prev[key]
		b ?= 0
		if a != b
			ret[key] = a - b

	ret


hash_items = (items) ->
	Object.keys(items).sort()
	.map (key) ->
		"#{key}:#{items[key]}"
	.join ","


describe '#auth', ->

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

	it 'should ok to get session and it must be a first connection and the results...', (next) ->
		get_session (require './gildong-auth.json'), (session_token,me,first_connection,attend_comp) ->
			expect(first_connection).to.be.true
			expect(exrules.attend).not.to.be.null
			expect(JSON.stringify(exrules.attend.added)).to.equal(JSON.stringify(attend_comp.added))
			prev_items = me.items ? {}
			request.get {
				url : "#{REST_URL}/member/#{me.id}"
				json : true
			}, (err,res,body) ->
				expect(err).to.be.null
				expect(res.statusCode).to.equal(200)

				current_items = {}
				for item, info of body.items
					current_items[item] = info.balance ? 0
				diff = get_diff_items(current_items, prev_items)
				expect(hash_items(diff)).to.equal(hash_items(attend_comp.added))

				next()

	it 'should ok to get session and it must not be a first connection', (next) ->
		get_session (require './gildong-auth.json'), (session_token,me,first_connection) ->
			expect(first_connection).to.be.false
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

	(require './test_tabom') (require './gildong-auth.json')

	after (next) ->
		get_session (require './gildong-auth.json'), (session_token) ->
			request.del {
				url : "#{REST_URL}/auth/unregister?session_token=#{session_token}"
			}, (err,res,body) ->
				expect(err).to.be.null
				expect(res.statusCode).to.equal(200)
				next()