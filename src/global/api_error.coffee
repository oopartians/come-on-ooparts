class ApiError
	constructor : (@code,@readable_message,@metas...) ->
		@metas.push stack:(new Error).stack


	toJSON : ->
		readable_message = @readable_message ? ''
		readable_message += @metas.map (m) ->
			JSON.stringify m
		.join ','

		error : @code
		readable_error : readable_message

class InternalApiError extends ApiError
	constructor : (@readable_message,@metas...) ->
		super "InternalError", @readable_message, @metas...


# console.log JSON.stringify new ApiError("COdE", "ReAdablE mEsSage")

global.ApiError = ApiError
global.InternalApiError = InternalApiError