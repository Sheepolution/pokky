Field = Object:extend()

function Field:new(data, x, y, size)
	Field.super.new(self)

	self.data = data

	self.x = x
	self.y = y

	self.width = #self.data[1]
	self.height = #self.data

	self.tileSize = size or 100
	self.margin = self.tileSize * 0.7
	self.fullTileSize = self.tileSize + self.margin

	self.tileObjects = buddies.new()

	self.tileData = {}

	self.inControl = true

	self.scale = 1

	for i,v in ipairs(self.data) do
		self.tileData[i] = {}
		for j,w in ipairs(v) do
			local tile
			if w > 0 then
				tile = Tile(self.x + j * (self.tileSize + self.margin), self.y + i * (self.tileSize + self.margin), self.tileSize, w)
				self.tileObjects:add(tile)
			end
			self.tileData[i][j] = tile
		end
	end
end


function Field:update(dt)
	self.tileObjects:update(dt)
end


function Field:draw()
	love.graphics.push()
	love.graphics.scale(self.scale)
	self.tileObjects:draw()
	love.graphics.pop()
	-- for i,v in ipairs(self.data) do
	-- 	for j,w in ipairs(v) do
	-- 		love.graphics.print(w, self.x + j * 120, self. y + i * 120, 0, 4, 4)
	-- 	end
	-- end
end


function Field:moveTiles(x, y, t)
	if lume.any(self.tileObjects, function (a) return a.tween end) then return end
	local dataTables = {self.data, self.tileData}
	for _,data in ipairs(dataTables) do
		local data_copy = {}
		for i,v in ipairs(data) do
			data_copy[i] = lume.clone(v)
		end

		for k,v in pairs(t) do
			data[y + v[2]][x + v[1]] = data_copy[y + k[2]][x + k[1]]
		end
	end

	for k,v in pairs(t) do
		local tile = self.tileData[y + v[2]][x + v[1]]
		local x = tile.x + (v[1] - k[1]) * (self.tileSize + self.margin)
		local y = tile.y + (v[2] - k[2]) * (self.tileSize + self.margin)
		tile:moveTo(x, y)
	end

	-- for i,v in ipairs(self.data) do
	-- 	for j,w in ipairs(v) do
	-- 	end
	-- end
end


function Field:__tostring()
	return lume.tostring(self, "Field")
end