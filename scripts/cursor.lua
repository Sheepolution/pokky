Cursor = Rect:extend()

function Cursor:new(x, y, width, height, field)
	Cursor.super.new(self, x, y, width, height)
	self.field = field
	self.alpha = 0.3
end


function Cursor:update(dt)
	if not self.field.automated then
		if Key:isPressed("right") then
			self:moveRight()
		elseif Key:isPressed("left") then
			self:moveLeft()
		elseif Key:isPressed("down") then
			self:moveDown()
		elseif Key:isPressed("up") then
			self:moveUp()
		end
	end
end


function Cursor:moveRight()
	if self.x + (self.width-1) < self.field.width then
		self.x = self.x + 1
	end
end


function Cursor:moveLeft()
	if self.x > 1 then
		self.x = self.x - 1
	end
end


function Cursor:moveUp()
	if self.y > 1 then
		self.y = self.y - 1
	end
end


function Cursor:moveDown()
	if self.y + (self.height-1) < self.field.height then
		self.y = self.y + 1
	end
end


function Cursor:draw()
	-- love.graphics.push()
	-- love.graphics.scale(self.field.tileSize + self.field.margin)
	-- Cursor.super.draw(self)
	-- love.graphics.pop()
end


function Cursor:__tostring()
	return lume.tostring(self, "Cursor")
end