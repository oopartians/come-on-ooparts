check_same_day = (A,B) ->
	A.getFullYear() == B.getFullYear() && A.getMonth() == B.getMonth() && A.getDate() == B.getDate()

get_yesterday = (T) ->
	new Date(T.getFullYear(), T.getMonth(), T.getDate() - 1)

check_yesterday = (A,B) ->
	B_yesterday = get_yesterday B
	A_normalized = new Date(A.getFullYear(), A.getMonth(), A.getDate())
	A_normalized.getTime() == B_yesterday.getTime()

module.exports =
	get_yesterday : get_yesterday
	check_same_day : check_same_day
	check_yesterday : check_yesterday