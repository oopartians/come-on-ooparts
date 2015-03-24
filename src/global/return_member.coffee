_ = require 'underscore'

ReturnMember = (member) ->
	a = _.omit member, 'password'
	
	a.id = a._id.toString()
	delete a._id

	a

global.ReturnMember = ReturnMember