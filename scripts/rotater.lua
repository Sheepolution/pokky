Rotater = Mode:extend()

function Rotater:new(...)
	Rotater.super.new(self, ...)
	self.cursor = Cursor(1, 1, 2, 2, self)
	self.cursors:add(self.cursor)
end


function Rotater:update(dt)
	Rotater.super.update(self, dt)

end


function Rotater:draw()
	Rotater.super.draw(self)
end


function Rotater:moveLeft()
	self:moveTiles(self.cursor.x, self.cursor.y,
	{
	[{0, 0}] = {0, 1},
	[{0, 1}] = {1, 1},
	[{1, 1}] = {1, 0},
	[{1, 0}] = {0, 0}})
end

Rotater.moveUp = Rotater.moveLeft

function Rotater:moveRight()
	self:moveTiles(self.cursor.x, self.cursor.y,
	{
	[{0, 0}] = {1, 0},
	[{1, 0}] = {1, 1},
	[{1, 1}] = {0, 1},
	[{0, 1}] = {0, 0}})
end

Rotater.moveDown = Rotater.moveRight


function Rotater:__tostring()
	return lume.tostring(self, "Rotater")
end