class @StatusLoadUrl

	constructor: (@element) ->
		@stateUrl = @$().attr('state-load-url')
		@startCheck()
		@maxRetry = 10

	$: () ->
		$(@element)

	startCheck: (url) ->
		@retry = 0
		@checkID = setInterval(() => 
			$.ajax({
				type: 'GET',
				url: @stateUrl,
				dateType: 'json'
			}).success @checkStatus.bind(@)
		, 4000)

	checkStatus: (data) ->
		@retry++
		if (data.state == 'done')
			@statusDone(data)
			clearInterval(@checkID)
		else if @retry >= @maxRetry
			@closeCheck()
		else if (data.state == 'pending')
			# continue
		else  
			@closeCheck()

	statusDone: (data) ->
		@$().attr('src', data.url)

	closeCheck: () ->
		@retry = 0
		clearInterval(@checkID)
