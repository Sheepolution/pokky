Swapper = Mode:extend()

function Swapper:new(...)
	Swapper.super.new(self, ...)
	self.cursor = Cursor(1, 1, 2, 2, self)
	self.cursors:add(self.cursor)
end


function Swapper:draw()
	Swapper.super.draw(self)
end


function Swapper:moveLeft()
	self:moveTiles(self.cursor.x, self.cursor.y,
	{
	[{0, 0}] = {1, 0},
	[{0, 1}] = {1, 1},
	[{1, 0}] = {0, 0},
	[{1, 1}] = {0, 1}})
end

Swapper.moveRight = Swapper.moveLeft

function Swapper:moveUp()
	self:moveTiles(self.cursor.x, self.cursor.y,
	{
	[{0, 0}] = {0, 1},
	[{1, 0}] = {1, 1},
	[{0, 1}] = {0, 0},
	[{1, 1}] = {1, 0}})
end

Swapper.moveDown = Swapper.moveUp


function Swapper:__tostring()
	return lume.tostring(self, "Swapper")
end