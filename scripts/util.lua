Util = {}


function Util.createData(size, colors)
	local t = {}
	local c = lume.numbers(colors)

	for i=1,size do
		t[i] = {}
		for j=1,size do
			for i,v in ipairs(c) do
				-- print(i,v)
			end
			local a = math.random(1, #c)
			t[i][j] = c[a]
			table.remove(c, a)
			if #c == 0 then
				c = lume.numbers(colors)
			end
		end
	end
	return t
end


function Util.copyData(data)
	local t = {}
	for i,v in ipairs(data) do
		t[i] = {}
		for j,w in ipairs(v) do
			t[i][j] = w
		end
	end
	return t
end


function Util.shuffleData(data)
	local t = Util.copyData(data)
	local t2 = {}
	for i,v in ipairs(t) do
		for j,w in ipairs(v) do
			table.insert(t2, w)
		end
	end
	t2 = lume.shuffle(t2)
	for i,v in ipairs(data) do
		for j,w in ipairs(v) do
			t[i][j] = t2[#t2]
			table.remove(t2, #t2)
		end
	end
	return t
end