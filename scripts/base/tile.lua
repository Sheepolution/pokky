local Tile = Entity:extend()

function Tile:new(x, y, width, height, i, p)
	Tile.super.new(self, x, y)
	self.width = width or 1
	self.height = height or 1
	self.separatePriority:set(1000)
	self.scale:set(1.005) --To hide bleeding
	self.id = i
	self.addIgnoreOverlap(Tile)
	self.visible = false
	self.immovable = true
end


-- function Tile:postNew()
-- 	Tile.super.postNew(self)
-- 	-- if self.id == 2 then
-- 	-- 	self:setSlope(16, 0)
-- 	-- elseif self.id == 3 then
-- 	-- 	self:setSlope(0, 16, true)
-- 	-- end
-- end


-- function Tile:update(dt)
-- 	Tile.super.update(self, dt)
-- end


-- function Tile:draw()
-- 	Tile.super.draw(self)
-- 	if self.slope then
-- 		local p = PlayManager.world.player
-- 		love.graphics.line(p:centerX(), p:centerY(), p:centerX(), self:getHeight(p:centerX()))
-- 		love.graphics.line(self.x, p:centerY(), self.x + self.width, p:centerY())
-- 	end
-- end


-- function Tile:onOverlap(e)
-- 	if e:is(Player) or e:is(Creature) then
-- 		if not self.slope then
-- 			return Tile.super.onOverlap(self, e)
-- 		else
-- 			local x = e:centerX()
-- 			if x >= self.x and x <= self.x + self.width then
-- 				local height = self:getHeight(x)
-- 				if self:touchesSlope(e, height) then
-- 					print("???	")
-- 					print(e:bottom(), height)
-- 					e.velocity.y = 0
-- 					e:bottom(height)
-- 					e:onSeparate(self, "y")
-- 					return true
-- 				end
-- 				-- 	e.velocity.y = 0
-- 				-- 	if self.slope == 8 then
-- 				-- 		e.velocity.x = 15
-- 				-- 	else
-- 				-- 		e.velocity.x = 20
-- 				-- 	end
-- 				-- end
-- 			end
-- 		end
-- 	end
-- end


-- function Tile:getHeight(x)
-- 	if self.downwards then
-- 		return self.y + self.slope * (math.abs(self.x - x) / self.width)
-- 	else
-- 		return self.y + self.slope - ((math.abs(self.x - x) / self.width) * self.slope)
-- 	end
-- end


-- function Tile:overlaps(e)
-- 	local t = Tile.super.overlaps(self, e)
-- 	if t then
-- 		for i,v in ipairs(t) do
-- 			local his = e
-- 			if self.slope then
-- 				local x = his:centerX()
-- 				if x >= self.x and x <= self.x + self.width then
-- 					return self:touchesSlope(his, self:getHeight(x)) and t or false
-- 				end
-- 			else
-- 				return t
-- 			end
-- 		end
-- 	end
-- end


-- function Tile:touchesSlope(e, height)
-- 	return e:bottom() > height
-- end



-- function Tile:setSlope(s, y, d)
-- 	self.slope = s
-- 	self.downwards = d
-- 	-- self.solid = false
-- end


function Tile:__tostring()
	return lume.tostring(self, "Tile")
end

return Tile