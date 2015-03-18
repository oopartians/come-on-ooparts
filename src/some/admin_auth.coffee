module.exports = (req,res,next) ->
	return next {error:"InvalidAdminAccess", readable_error:"Not even a member"} unless req.member?
	return next {error:"InvalidAdminAccess", readable_error:"not an admin member"} unless req.member.admin
	next()