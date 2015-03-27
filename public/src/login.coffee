app = angular.module 'loginApp'

get_cookie_chunks = ->
	document.cookie
		.split ';'
		.map (chunk) ->
			[lhs,rhs] = chunk.split '='
			key : lhs.trim()
			value : rhs.trim()

set_cookie_chunks = (list) ->
	document.cookie = list.map (c) ->
		"#{c.key}=#{c.value}"
	.join '; '

get_cookie = (key) ->
	{cookie} = document
	return null unless cookie?
	_ref = _.find get_cookie_chunks(), (c) -> c.key == key
	if _ref?
		_ref.value
	else
		null

set_cookie = (key,value) ->
	chunks = get_cookie_chunks()
	_ref = _.find chunks, (c) -> c.key == key
	if _ref?
		_ref.value = value
	else
		chunks.push key:key, value:value

	set_cookie_chunks(chunks)


app.controller 'LoginCtrl', ['$scope','$resource',($scope,$resource) ->

	R_session = $resource "/auth/session"

	$scope.login = (name,pw) ->
		R_session.save {}, {name:name,password:pw}, (data) ->
			get_cookie(data)
			
			console.log "succeeded!"

		, (err) ->
			alert "got error : #{JSON.stringify err}"

]