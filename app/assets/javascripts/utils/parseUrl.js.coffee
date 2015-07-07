@parseURL = (url) ->
	parser = document.createElement('a')
	parser.href = url;
	parser
