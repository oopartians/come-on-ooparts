module.exports = (req,res,next) ->
	return next new ApiError("InvalidAdminAccess", "Not even a member") unless req.member?
	return next new ApiError("InvalidAdminAccess", "not an admin member") unless req.member.admin
	next()