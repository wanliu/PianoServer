@parseURL = (url) ->
	parser = document.createElement('a')
	parser.href = url;
	parser


@getQueryVars = (queryString) ->
    vars = {}
    hashes = queryString.slice(queryString.indexOf('?') + 1).split('&')
    for hash in hashes
      [key, value] = hash.split('=')
      vars[key] = value

    return vars
