IGNORE_METAS = [ undefined, '', 'viewport', 'csrf-param', 'csrf-token' ]

class @MetaDataParser
	@defaultOptions: { splitChar: ':' }

	parse: (@options) ->
		data = {}
		$metas = document.getElementsByTagName('meta')
		for meta in $metas
			{name, attributes: { property }, content} = meta

			if property != '' and property?
				@writeMetaProperties(data, property.nodeValue, content)
			else if !!~IGNORE_METAS.indexOf(name)
				continue 
			else
				@writeMeta(data, name, content)
		data

	writeMetaProperties: (obj, key, value) ->
		names = key.split(MetaDataParser.defaultOptions.splitChar)

		parent = obj
		for name, i in names
			target = parent[name]
			if target?
				if names.length == i + 1
					if @_isEmpty(target) 
						parent[name] = @convertDataType(value)
					else if $.type(target) == 'array' 
						parent[name].push @convertDataType(value)
					else if @_isConstants(target)
						parent[name] = [ @convertDataType(value) ]
				else
					parent = parent[name]
			else
				if names.length == i + 1
					parent[name] = @convertDataType(value)
				else
					parent[name] = {}
					parent = parent[name]	

	writeMeta: (obj, key, value) ->
		obj[key] = value

	convertDataType: (value) ->
		return null	unless value?
		ret = null

		reISO = /^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2}(?:\.{0,1}\d*))(?:Z|(\+|-)([\d|:]*))?$/;
		try 
			a = reISO.exec(value);
			ret = if a
				new Date(value)
			else if value.trim() == ''
				null
			else
				JSON.parse(value)
		catch 
			ret = value
			
		ret 


	# read: (obj, key) ->

	_isConstants: (obj) ->
		jQuery.type( obj ) != 'object' 

	_isEmpty: (obj) ->
		typeof obj == 'undefined' or obj == null or obj == ''



metaParser = new MetaDataParser
$ ->
	window.metadata = metaParser.parse()
