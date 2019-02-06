TileButton = Tile:extend()

function TileButton:new(x, y, size, id, img)
	TileButton.super.new(self, x, y, size, id)
	self.highlightFactor = 1.2
	self.image = Sprite(0, 0, img)
	self.image:center(self.x + self.size/2, self.y + self.size/2)
end


function TileButton:update(dt)
	TileButton.super.update(self, dt)
	-- if self:overlaps(Mouse) then
	-- 	self:highlight()
	-- else
	-- 	self:stopHighlight()
	-- end
end


function TileButton:draw()
	TileButton.super.draw(self)
	self.image:draw()
end


function TileButton:__tostring()
	return lume.tostring(self, "TileButton")
end