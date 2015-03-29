app = angular.module 'loginApp', ['ngResource']

app.run ->

get_cookie_chunks = ->
	document.cookie
		.split ';'
		.map (chunk) ->
			return unless chunk?
			return unless chunk.trim()
			[lhs,rhs] = chunk.split '='
			key : lhs.trim()
			value : rhs.trim()
		.filter (a) -> a?

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

	console.log "session_token : #{get_cookie("session_token")}"
	console.log "redirect_url : #{redirect_url}"

	$scope.login = (name,pw) ->
		R_session.save {}, {name:name,password:pw}, (data) ->
			console.log "succeeded to get token : #{data.session_token}"
			set_cookie("session_token", data.session_token)
			location.href = redirect_url
		, (err) ->
			if err.data?.error = "NoSuchMember"
				alert "해당 이름과 비밀번호를 가진 멤버를 찾지 못했습니다."
			else if err.data?.error?
				alert "로그인 실패 : #{err.data.error}"
			else
				alert "로그인 실패"

]