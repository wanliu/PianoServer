module CombinationHash
	extend self

	def combination_array(a, b)
		arr = []
		a.each do |i|
			b.each do |j|
				arr.push [i, j]
			end
		end
		arr
	end

	def combination_3array(a, b, c)
		arr = []
		a.each do |i|
			b.each do |j|
				c.each do |k|
					arr.push [i, j, k]
				end
			end
		end
		arr
	end

	def combination_arrays(*args, &block)
		each_combine(args, &block)
	end

	def each_combine(arrs, level = 0, args = [], results = [], &block)
		arrs[level].each do |i|
			if level < arrs.length - 1 
				each_combine(arrs, level + 1, args + [i], results, &block )
			else
				results.push block_given? ? yield(*(args + [i])) : [*args, i] 
			end
		end
		results
	end

	def combination_hash(*args, &block)
		each_combine_hash(args, &block)
	end

	def each_combine_hash(arrs, level = 0, args = {}, results = [], &block)
		arrs[level].each do |key, values|
			values.each do |id, value|
				hash = Hash[key, id]
				if level < arrs.length - 1 
					each_combine_hash(arrs, level + 1, args.merge(hash), results, &block )
				else
					results.push block_given? ? yield(args.merge(hash)) : args.merge(hash)
				end
			end
		end
		results
	end	
end