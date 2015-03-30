class Result
	constructor : (@rule) ->
		throw new Error("no rule provided!") unless @rule?
		@

	toJSON : ->
		removed : @rule.removed ? {}
		added : @rule.added ? {}


module.exports = (global) ->

	global.exchange = (member_id,exrule,next) ->

		{name,removed,added} = exrule

		removed ?= {}
		added ?= {}
		force = false

		if Object.keys(removed).length == 0 && Object.keys(added).length == 0
			next new InternalApiError("Invalid exchange rule(#{name}) : no changes")
			return

		Q = _id : member_id
		inc = {}
		inc["items.v"] = 1
		set = {}
		now = new Date
	
		for k,v of removed
			unless force
				Q["items.#{k}.balance"] = $gte:v
			inc["items.#{k}.balance"] = -v
			set["items.#{k}.last_spend_date"] = now
			set["items.#{k}.last_spend_datetime"] = now.getTime()
			set["items.#{k}.last_update_date"] = now
			set["items.#{k}.last_update_datetime"] = now.getTime()

		for k,v of added
			inc["items.#{k}.balance"] ?= 0
			inc["items.#{k}.balance"] += v
			set["items.#{k}.last_update_date"] = now
			set["items.#{k}.last_update_datetime"] = now.getTime()

		U =
			$inc:inc
			$set:set

		global.col("member").update Q, U, (err,nr_changed) ->
			if err?
				next new InternalApiError("db error", err)
				return

			if nr_changed == 0
				next (new ApiError("NotEnoughBalance")).status(403)
				return

			next null, new Result(exrule)


	return