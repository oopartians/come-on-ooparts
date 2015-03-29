module.exports = (global) ->
	{sessions} = global

	(req,res,next) ->
		# Check session token with url parameter
		{session_token} = req.query
		if session_token?
			member_info = sessions[session_token]
			unless member_info?
				return next (new ApiError("NoSuchSession", "session is invalid or expired")).status(403)
			req.member = member_info

		# Check session token with cookie
		if req.cookies? && req.cookies.session_token?
			member_info = sessions[req.cookies.session_token]
			if member_info?
				req.member = member_info

		next()