class ApiError
	constructor : (@code,@readable_message,@metas...) ->
		@stack = (new Error).stack
		@class = 'ApiError'


	toJSON : ->
		readable_message = @readable_message ? ''
		readable_message += @metas.map (m) ->
			JSON.stringify m
		.join ','

		error : @code
		readable_error : readable_message
		stack : @stack

	status : (@statuscode) ->
		@

class InternalApiError extends ApiError
	constructor : (@readable_message,@metas...) ->
		super "InternalError", @readable_message, @metas...
		@statuscode = 500


# console.log JSON.stringify new ApiError("COdE", "ReAdablE mEsSage")

global.ApiError = ApiError
global.InternalApiError = InternalApiError