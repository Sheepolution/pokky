local Tilemap = Object:extend()

local Tile = require "base.tile"

function Tilemap:new(map)
	self.tiles = buddies.new()



	self.currentPart = nil
	self.currentID = nil
	self.newPartHandler = nil
	self.objectHandler = nil
	self.layerHandler = nil

	self.hasBorders = false

	self.mergeTiles = true
	self._cache = {}

	if map then
		self:loadMap(map)
	end
end


function Tilemap:update(dt)
	-- if false then
		if self.follow then
			self:preloadPartsNearFollow()
			if not self:overlapsWithPart(self.follow) then
				self:initNewPart()
			end
		end
	-- end
end


function Tilemap:loadMap(name)
	local map = love.filesystem.read("assets/maps/" .. name .. ".json")
	assert(map, "The room assets/maps/" .. name .. ".json doesn't exist")
	
	self.map = json.decode(map)
	self.columns = self.map.width
	self.tileWidth = self.map.tilewidth
	self.tileHeight = self.map.tileheight

	if self.map.properties and self.map.properties.background then
		self.background = Asset.image("tilesets/" .. self.map.properties.background)
		self.backgroundRepeat = true
	end

	--Convert the long paths into short paths for Asset.image()
	for i,v in ipairs(self.map.tilesets) do
		v.image = v.image:gsub(".-images/", ""):gsub("%.png", "")
	end

	local border = lume.match(self.map.layers, function (a) return a.name == "borders" end)

	if border then
		self.hasBorders = true
		self:splitMap(border)
		self:loadPart(1, true)
	else
		self:loadAll()
	end

end


function Tilemap:handleTileLayer(layer, part)
	local part = part or self.currentPart
	local ignores = {}
	if part.loaded then return end
	math.randomseed(1)
	for i,v in ipairs(part.numbers) do
		i = v
		v = layer.data[v]
		if v ~= 0 and not ignores[i] then
			local tileset
			local img
			--We check what tileset the tile is using
			local ov = v
			for i,set in ipairs(self.map.tilesets) do
				if not set.firstgid or v >= set.firstgid then
					tileset = set
				end
				if v < set.firstgid or i == #self.map.tilesets then
					v = v - tileset.firstgid + 1
					break
				end
			end

			local tilesetprops = tileset.properties
			local tileprops = tileset.tileproperties and tileset.tileproperties[tostring(v-1)] or {} 

			--For when tiles have multiple images (grass1, grass2..)
			if tilesetprops and tilesetprops.amount then
				img = tileset.image:sub(1, -2)
				img = img .. math.random(tonumber(tilesetprops.amount))
			else
				img = tileset.image
			end


			local tile
			if layer.properties and layer.properties.type == "solid" then
				-- print(tileprops.type, v)
				local typ = tileprops.type
				if typ then
					typ = lume.tovalue(typ)
				else
					typ = Tile
				end
				-- print(typ)
				--Merge tiles
				local xlen, ylen = 1, 1
				local j = 1

				if self.mergeTiles then
					while true do
						if layer.data[i + j] and layer.data[i + j] == ov and self:getTileX(i + j) < part.right then
							ignores[i + j] = true
							xlen = xlen + 1
						else
							break
						end
						j = j + 1
					end

					j = 1
					while xlen == 1 do
						if layer.data[i + j * layer.width] and layer.data[i + j * layer.width] == ov and self:getTileY(i + j * layer.width) < part.bottom then
							ignores[i + j * layer.width] = true
							ylen = ylen + 1
						else
							break
						end
						j = j + 1
					end
				end
				---------
				tile = typ(self:getTileX(i), self:getTileY(i),
				self.tileWidth * xlen, self.tileHeight * ylen, v)
				if not self.mergeTiles then
					tile:setImage(img)
					tile.visible = true
				end

			else
				tile = Sprite(self:getTileX(i), self:getTileY(i),
				img, self.tileWidth+2, self.tileHeight+2)
				tile.anim:add("_", v)
				tile.scale:set(1.005)
			end

			if tilesetprops then
				for k,v in pairs(tilesetprops) do
					if k ~= "amount" then
						tile[k] = lume.tovalue(v)
					end
				end
			end

			if tileprops then
				for k,v in pairs(tileprops) do
					tile[k] = lume.tovalue(v)
				end
			end


			local stop = false
			if self.layerHandler then
				stop = self.layerHandler(layer, tile, part)
			end
			if not stop then
				self.tiles:add(tile)
				tile:done()
			end
		end
	end
	math.randomseed()
end

local function prop(obj, name, value)
	local list = lume.split(name, ".")
	for i,v in ipairs(list) do
		if i < #list then
			obj = obj[v]
		end
	end
	obj[list[#list]] = value
end


function Tilemap:handleObjectLayer(layer)
	for i,v in ipairs(layer.objects) do
		if v.x >= self.currentPart.left and v.x < self.currentPart.right
		and v.y >= self.currentPart.top and v.y < self.currentPart.bottom then
			local ent = GLOBAL[v.name](v.x, v.y)
			if ent.width == 0 then
				ent.width = v.width
				ent.height = v.height
			end
			--Set properties


			if v.properties then
				for k,p in pairs(v.properties) do
					prop(ent, k, lume.tovalue(p))
				end
			end

			self.objectHandler(ent)
		end
	end
end


function Tilemap:handleEventsLayer(layer)
	for i,v in ipairs(layer.objects) do
		if v.x > self.currentPart.left and v.x < self.currentPart.right
		and v.y > self.currentPart.top and v.y < self.currentPart.bottom then
			local event = Event(v.name, v.x, v.y, v.width, v.height)
			if v.properties then
				for k,p in pairs(v.properties) do
					prop(event, k, lume.tovalue(p))
				end
			end

			self.eventHandler(event)
		end
	end
end



function Tilemap:splitMap(border)
	self.parts = {}
	local base = lume.match(border.data, function (a) return a > 0 end) - 1
	for p=0,1000 do
		local t = {}
		local lookingForEnd = false
		local succes = false

		for i,v in ipairs(border.data) do
			local x, y = self:getMapX(i), self:getMapY(i)
			v = v - base
			if v == 1 or v == 2 then
				if lookingForEnd then
					succes = true
					if v == 1 then -- We encounter a left-upper corner side
						-- print("Found another upper-left corner", i, x, y)
						if t.right then
							if t.bottom then
								-- print("Is it inside our borders?", x >= t.left, x <= t.right)
								if x <= t.right then --This is our match
									-- print("Yes! We found a match!")
									-- print("RESULTS: t.left = ", t.left, "t.top = ", t.top, "t.right =", t.right, "t.bottom = ", t.bottom)
									-- print("---------------------")
									-- print("---------------------")
									border.data[t.start] = 0
									border.data[t.stop] = 0
									t.start = t.start
									t.stop = t.stop
									break
								end
							else
								-- print("Is this upper-left corner closer to us than the other?", x > t.left, x <= t.right)
								if x > t.left and x <= t.right then
									t.right = x
									-- print("Our bottom-right corner should be inside here", x)
								end
							end
						else
							if x > t.left then
								-- print("First other encounter. Our bottom-right corner should be inside here", x)
								t.right = x
							else
								-- print("This is further to the left than us", x)
							end
						end
					else
						-- print("Found bottom-right corner. Is it on our right side?", x >= t.left)
						if x >= t.left then
							-- print("Do we already have a bottom-right corner?", t.bottom)
							if t.bottom then -- If we already have an bottom-right corner
								-- print("We do, is it closer the the right than t.right?", x, t.right, x <= t.right)
								if x <= t.right then -- Check if this one is nearer
									-- print("Yes, this bottom-right corner is nearer", i, x, y)
									t.stop = i
									t.right = x
									t.bottom = y
								else
									-- print("Nope, this corner is further away")
								end
							else
								-- print("We don't, is it closer though?", x, t.right)
								if not t.right or x < t.right then
									-- print("Yes! It's a first bottom-right corner", i, x, y)
									t.stop = i
									t.right = x
									t.bottom = y
								else
									-- print("Nope, it's further away")
								end
							end
						end
					end
				else
					if v == 1 then
						-- print("Found a new upper-left corner", i, x, y)
						t.start = i
						t.left = x
						t.top = y
						lookingForEnd = true
					end
				end
			else
				border.data[i] = 0
			end

			if i == #border.data then
				if t.start then
					assert(t.stop, "No stop!?")
					-- print( "END OF THE ROAD")
					-- print("RESULTS: t.left = ", t.left, "t.top = ", t.top, "t.right =", t.right, "t.bottom = ", t.bottom)
					-- print("---------------------")
					-- print("---------------------")
					border.data[t.start] = 0
					border.data[t.stop] = 0
					t.start = t.start
					t.stop = t.stop
				end
			end
		end

		if not succes then
			break
		end

		-- print(t.start, t.stop, t.left, t.top, t.right, t.bottom)
		t.left = self:getMapX(t.start)
		t.top = self:getMapY(t.start)
		t.right = self:getMapX(t.stop) + 1
		t.bottom = self:getMapY(t.stop) + 1

		t.numbers = self:getNumbersInBorder(t)
		t.left = t.left * self.tileWidth
		t.right = t.right * self.tileWidth-- + self.tileWidth/2
		t.top = t.top * self.tileHeight
		t.bottom = t.bottom * self.tileHeight --+ self.tileHeight/2
		t.id = #self.parts + 1
		t.loaded = false

		table.insert(self.parts, t)
	end
end


function Tilemap:getNumbersInBorder(border)
	local t = {}
	for i=border.start, border.stop do
		local x = self:getMapX(i)
		if x >= border.left and x <= border.right then
			table.insert(t, i)
		end
	end

	return t
end


function Tilemap:createPart(p)
	if p == "all" then
		self.parts = {}
		local t = {}
		t.start = 1
		t.stop = self.map.width * self.map.height
		t.left = self:getMapX(t.start)
		t.top = self:getMapY(t.start)
		t.right = self:getMapX(t.stop) + 1
		t.bottom = self:getMapY(t.stop) + 1

		t.numbers = self:getNumbersInBorder(t)
		t.left = t.left * self.tileWidth
		t.right = t.right * self.tileWidth
		t.top = t.top * self.tileHeight
		t.bottom = t.bottom * self.tileHeight
		t.id = 1
		t.loaded = false

		table.insert(self.parts, t)

		self.currentID = 1
		self.currentPart = t
	end
end


function Tilemap:initNewPart()
	local part, i = lume.match(self.parts, function (a)
			--Search for the part that we need to init
			return self:overlapsWithPart(a, self.follow) and a~=self.currentPart
		end)
	if i then
		self:loadPart(i)
	end
end


function Tilemap:loadPart(i, first)
	local prev = self.currentID
	self.currentID = i
	self.currentPart = self.parts[i]

	-- PlayCamera.cam:setWorld(self.currentPart.left, self.currentPart.top,
	-- 	self.currentPart.right - self.currentPart.left,
	-- 	self.currentPart.bottom - self.currentPart.top)

	local stop = false
	if self.newPartHandler and not first then
		stop = self.newPartHandler(part, i, prev)
	end

	if not stop then
		for n,layer in ipairs(self.map.layers) do
			if layer.data then -- If this layer is a tilemap
				self:handleTileLayer(layer)
			else --It's an object layer
				if layer.name == "objects" then
					if self.objectHandler then
						self:handleObjectLayer(layer)
					end
				elseif layer.name == "events" then
					if self.eventHandler then
						self:handleEventsLayer(layer)
					end
				end
			end
		end
	end
	self.currentPart.loaded = true

	if self.onNewPart then
		self.onNewPart(self.currentPart)
	end
end


function Tilemap:loadAll()
	self:createPart("all")
	self:loadPart(1, true)
end


function Tilemap:preloadPart(i)
	if not self.parts[i].loaded then
		if self._cache[i] then
			for i,v in ipairs(self._cache[i]) do
				self.tiles:add(v)
			end
		else
			for n,layer in ipairs(self.map.layers) do
				if layer.data then -- If this layer is a tilemap
					self:handleTileLayer(layer, self.parts[i])
				end
			end
		end
		-- print("Part" .. i .. " loaded")
		self.parts[i].loaded = true
	end
end


function Tilemap:unloadPart(i)
	if self.parts[i].loaded then
		-- if not self._cache[i] then
		-- 	local t = {}
		-- 	self.tiles:removeIf(function (a)
		-- 		if self:overlapsWithPart(self.parts[i], a) then
		-- 			table.insert(t, a)
		-- 			return true
		-- 		end
		-- 	end)
		-- 	self._cache[i] = t
		-- else
		-- 	for i,v in ipairs(self._cache[i]) do
		-- 		self.tiles:remove(v)
		-- 	end
		-- end
		-- self.parts[i].loaded = false
	end
end


function Tilemap:getTileX(i)
	i = i - 1
	return (i % self.columns) * self.tileWidth
end


function Tilemap:getTileY(i)
	i = i - 1
	return math.floor(i/self.columns) * self.tileHeight
end


function Tilemap:getMapX(i)
	i = i - 1
	return (i % self.columns)
end


function Tilemap:getMapY(i)
	i = i - 1
	return math.floor(i/self.columns)
end


function Tilemap:setFollow(follow)
	self.follow = follow
end


function Tilemap:getTiles()
	return self.tiles
end


function Tilemap:overlapsWithPart(part, obj)
	if not obj then  obj = part part = self.currentPart end
	return part.left < obj.x + obj.width
	and part.right > obj.x
	and part.top < obj.y + obj.height
	and part.bottom > obj.y
end


function Tilemap:preloadPartsNearFollow()
	for i,v in ipairs(self.parts) do
		local succes = false
		if not self:overlapsWithPart(v, self.follow) then
			if v.left < self.follow.x and v.right > self.follow.x then
				if  math.abs(self.follow.y + self.follow.height - v.top) < self.tileHeight or
				   	math.abs(self.follow.y - v.bottom) < self.tileHeight then
					self:preloadPart(i)
					succes = true 	
				end
			elseif v.top < self.follow.y and v.bottom > self.follow.y then
				if  math.abs(self.follow.x + self.follow.width - v.left) < self.tileWidth or
				   	math.abs(self.follow.x - v.right) < self.tileWidth then
					self:preloadPart(i)
					succes = true
				end
			end
		else
			succes = true
		end

		if not succes then
			self:unloadPart(i)
		end
	end
end


function Tilemap:setObjectHandler(f)
	self.objectHandler = f
end


function Tilemap:setEventHandler(f)
	self.eventHandler = f
end


function Tilemap:setNewPartHandler(f)
	self.newPartHandler = f
end


function Tilemap:setLayerHandler(f)
	self.layerHandler = f
end


function Tilemap:__tostring()
	return lume.tostring(self, "Tilemap")
end

return Tilemap