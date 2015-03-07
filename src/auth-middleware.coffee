module.exports = (global) ->
	{sessions} = global

	(req,res,next) ->
		{session_token} = req.query
		if session_token?
			member_info = sessions[session_token]
			unless member_info?
				return next "NoSuchSession"
			req.member = member_info

		next()