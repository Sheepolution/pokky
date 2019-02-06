Mode = Field:extend()

function Mode:new(data, x, y, size)
	Mode.super.new(self, data, x, y, size)
	self.cursors = buddies.new()
	self.tileObjects:set("autoHighlight", true)
end


function Mode:update(dt)
	if not self.automated and self.inControl then
		if Key:isPressed("a") then
			LEVEL.start = true
			PlaySound("pik")
			self:moveLeft()
		elseif Key:isPressed("d") then
			LEVEL.start = true
			PlaySound("pok")
			self:moveRight()
		elseif Key:isPressed("w") then
			LEVEL.start = true
			PlaySound("pek")
			self:moveUp()
		elseif Key:isPressed("s") then
			LEVEL.start = true
			PlaySound("pak")
			self:moveDown()
		end
	end

	if self.inControl then
		self.tileObjects:set("selected", false)
	end

	for i,v in ipairs(self.cursors) do
		if self.inControl then
			v:update(dt)
		end
		for i=1,v.height do
			for j=1,v.width do
				tile = self.tileData[v.y + i - 1][v.x + j - 1]
				if tile then
					tile.selected = true
				end
			end
		end
	end


	self.tileObjects:update(dt)
end


function Mode:draw()
	Mode.super.draw(self)
	self.cursors:draw()
end


function Mode:shuffleData()
	INSTANT_MOVEMENT = true
	--
	local directions = {"Left", "Right", "Up", "Down"}
	for i=1,100 do
		self["move" .. directions[math.random(1,4)]](self)
		self.cursors["move" .. directions[math.random(1,4)]](self.cursors)
	end
	self.cursors:set("x", 1)
	self.cursors:set("y", 1)
	--
	INSTANT_MOVEMENT = false
end



function Mode:__tostring()
	return lume.tostring(self, "Mode")
end