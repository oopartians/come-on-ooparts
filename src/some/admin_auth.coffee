module.exports = (req,res,next) ->
	return next (new ApiError("InvalidAdminAccess", "Not even a member")).status(401) unless req.member?
	return next (new ApiError("InvalidAdminAccess", "not an admin member")).status(403) unless req.member.admin
	next()