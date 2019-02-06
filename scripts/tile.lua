Tile = Block:extend()

Tile.colors = {
	{34, 116, 165},
	{255, 60, 56},
	{20, 186, 56},
	{241, 196, 15},
	{249, 105, 0},
	{255, 76, 133},
	{126, 49, 158},
	{126, 49, 58},
	{246, 10, 158}
}

function Tile:new(x, y, size, id)
	Tile.super.new(self, x, y, size)
	self.id = id
	self.color = Tile.colors[id]

	self.selected = false
	self.autoHighlight = false

end


function Tile:update(dt)
	Tile.super.update(self, dt)

	if self.autoHighlight then
		if self.selected then
			self:highlight()
		else
			self:stopHighlight()
		end
	end
end


function Tile:draw()
	Tile.super.draw(self)
end


function Tile:__tostring()
	return lume.tostring(self, "Tile")
end